const {
  SESv2Client,
  SendEmailCommand,
} = require("@aws-sdk/client-sesv2");

const ses = new SESv2Client({});

const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type,Accept",
  "Access-Control-Allow-Methods": "OPTIONS,POST",
};

function response(statusCode, body) {
  return {
    statusCode,
    headers,
    body: JSON.stringify(body),
  };
}

function parseBody(event) {
  if (!event.body) {
    return {};
  }

  const body = event.isBase64Encoded
    ? Buffer.from(event.body, "base64").toString("utf8")
    : event.body;

  return JSON.parse(body);
}

function getMethod(event) {
  return event.requestContext?.http?.method || event.httpMethod || "";
}

function sanitizeSubject(subject) {
  return subject.replace(/[\r\n]+/g, " ").trim().slice(0, 200);
}

async function sendOwnerNotification(contactData) {
  const fromEmail = process.env.SES_FROM_EMAIL;
  const recipientEmail = process.env.CONTACT_RECIPIENT_EMAIL;

  if (!fromEmail || !recipientEmail) {
    throw new Error("SES email configuration is missing.");
  }

  const subject = sanitizeSubject(contactData.subject);

  const command = new SendEmailCommand({
    FromEmailAddress: fromEmail,
    Destination: {
      ToAddresses: [recipientEmail],
    },
    ReplyToAddresses: [contactData.email],
    Content: {
      Simple: {
        Subject: {
          Data: subject ? `Portfolio contact: ${subject}` : "New portfolio contact",
          Charset: "UTF-8",
        },
        Body: {
          Text: {
            Data: [
              "New portfolio contact submission",
              "",
              `Name: ${contactData.name || "Not provided"}`,
              `Email: ${contactData.email}`,
              `Subject: ${contactData.subject || "Not provided"}`,
              "",
              "Message:",
              contactData.message,
            ].join("\n"),
            Charset: "UTF-8",
          },
        },
      },
    },
  });

  return ses.send(command);
}

async function sendVisitorAutoReply(contactData) {
  const fromEmail = process.env.SES_AUTO_REPLY_FROM_EMAIL;

  if (!fromEmail) {
    throw new Error("SES auto-reply configuration is missing.");
  }

  const visitorName = contactData.name || "there";

  const command = new SendEmailCommand({
    FromEmailAddress: fromEmail,
    Destination: {
      ToAddresses: [contactData.email],
    },
    Content: {
      Simple: {
        Subject: {
          Data: "Thanks for contacting Jacob Sidhu",
          Charset: "UTF-8",
        },
        Body: {
          Text: {
            Data: [
              `Hi ${visitorName},`,
              "",
              "Thank you for getting in touch. I’ve received your message and will respond as soon as possible.",
              "",
              "Best regards,",
              "Jacob Sidhu",
              "",
              "This is an automated acknowledgement. Please do not reply to this email.",
            ].join("\n"),
            Charset: "UTF-8",
          },
        },
      },
    },
  });

  return ses.send(command);
}

exports.handler = async (event) => {
  const method = getMethod(event);

  if (method === "OPTIONS") {
    return response(204, {});
  }

  if (method !== "POST") {
    return response(405, { message: "Method not allowed." });
  }

  let body;

  try {
    body = parseBody(event);
  } catch (error) {
    console.error("Invalid JSON body:", error);
    return response(400, { message: "Invalid JSON body." });
  }

  const contactData = {
    name: String(body.name || "").trim(),
    email: String(body.email || "").trim().toLowerCase(),
    subject: String(body.subject || "").trim(),
    message: String(body.message || "").trim(),
  };

  if (!contactData.email || !contactData.message) {
    return response(400, { message: "Email and message are required." });
  }

  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!emailPattern.test(contactData.email)) {
    return response(400, { message: "Please enter a valid email address." });
  }

  if (
    contactData.name.length > 100 ||
    contactData.email.length > 254 ||
    contactData.subject.length > 200 ||
    contactData.message.length > 5000
  ) {
    return response(400, { message: "One or more fields are too long." });
  }

  try {
    const ownerResult = await sendOwnerNotification(contactData);

    console.log("Owner notification sent:", {
      messageId: ownerResult.MessageId,
    });

    try {
      const autoReplyResult = await sendVisitorAutoReply(contactData);

      console.log("Visitor auto-reply sent:", {
        messageId: autoReplyResult.MessageId,
      });
    } catch (autoReplyError) {
      console.error("Visitor auto-reply failed:", {
        name: autoReplyError.name,
        message: autoReplyError.message,
      });
    }

    return response(200, {
      message: "Your message has been sent.",
    });
  } catch (error) {
    console.error("Contact email delivery failed:", {
      name: error.name,
      message: error.message,
    });

    return response(502, {
      message: "Your message could not be delivered. Please try again.",
    });
  }
};

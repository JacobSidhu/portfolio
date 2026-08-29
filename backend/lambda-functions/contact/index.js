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

exports.handler = async (event) => {
  if (event.requestContext?.http?.method === "OPTIONS") {
    return response(204, {});
  }

  if (event.requestContext?.http?.method !== "POST") {
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

  console.log("Contact message received:", {
    name: contactData.name,
    email: contactData.email,
    subject: contactData.subject,
    messageLength: contactData.message.length,
  });

  return response(200, {
    message: "Your message has been sent.",
  });
};

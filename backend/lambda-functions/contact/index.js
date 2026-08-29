exports.handler = async () => {
  console.log("Hello World");

  return {
    statusCode: 200,
    body: "Hello World"
  };
};
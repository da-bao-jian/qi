const { createHandler } = require("@metamask/snap-plugin");

const postMessageHandler = createHandler("postMessage");

postMessageHandler(async (request) => {
  const { message, signature } = request.params;

  // Send the message and signature to the Flask server
  const response = await fetch("http://localhost:5000/post_message", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message, signature }),
  });

  return await response.json();
});

postMessageHandler.addHandler();

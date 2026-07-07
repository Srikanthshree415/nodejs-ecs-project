import express from "express";
const app = express();
const PORT = process.env.PORT || 3000;

app.get("/", (_req, res) => {
  res.send("🚀 Welcome to nodejswebbasicapplication deployed on AWS ECS via Terraform + GitLab CI/CD");
});

app.get("/health", (_req, res) => {
  res.status(200).json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.listen(PORT, () => console.log(`✅ nodejswebbasicapplication running on port ${PORT}`));

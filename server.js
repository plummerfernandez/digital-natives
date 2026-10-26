import http from "node:http";
import { readFile, stat } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
const root = path.dirname(fileURLToPath(import.meta.url)),
  port = Number(process.env.PORT || 8080);
const types = {
  ".html": "text/html",
  ".js": "text/javascript",
  ".css": "text/css",
  ".json": "application/json",
  ".md": "text/plain",
  ".stl": "application/octet-stream",
  ".png": "image/png",
};
http
  .createServer(async (req, res) => {
    try {
      const url = new URL(req.url, "http://localhost"),
        relative = decodeURIComponent(url.pathname),
        file = path.resolve(
          root,
          "." + relative + (relative.endsWith("/") ? "index.html" : ""),
        );
      if (!file.startsWith(root + path.sep) || relative.includes("/archive/")) {
        res.writeHead(403);
        res.end("Forbidden");
        return;
      }
      const info = await stat(file);
      if (!info.isFile()) throw Error();
      res.writeHead(200, {
        "Content-Type": types[path.extname(file)] || "application/octet-stream",
        "Cache-Control": "no-cache",
      });
      res.end(await readFile(file));
    } catch {
      res.writeHead(404);
      res.end("Not found");
    }
  })
  .listen(port, "127.0.0.1", () =>
    console.log(`Digital Natives: http://localhost:${port}`),
  );

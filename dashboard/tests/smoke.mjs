// Smoke test: serve the built site under its base path and check every page loads cleanly.
import http from "http";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { chromium } from "playwright";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "build");
const base = "/nfl_platform";
const pages = ["", "teams", "league", "quarterbacks", "players", "streaks", "play-by-play", "injuries"];
const types = { ".html": "text/html", ".js": "text/javascript", ".css": "text/css", ".json": "application/json", ".svg": "image/svg+xml", ".png": "image/png", ".wasm": "application/wasm", ".ico": "image/x-icon" };

const server = http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split("?")[0]);
  if (!p.startsWith(base)) { res.writeHead(404); return res.end("404"); }
  let f = path.join(root, p.slice(base.length) || "/");
  if (fs.existsSync(f) && fs.statSync(f).isDirectory()) f = path.join(f, "index.html");
  if (!fs.existsSync(f)) { res.writeHead(404); return res.end("404"); }
  res.writeHead(200, { "content-type": types[path.extname(f)] || "application/octet-stream" });
  fs.createReadStream(f).pipe(res);
}).listen(4173);

const browser = await chromium.launch();
const page = await browser.newPage();
let failures = 0;
const errors = [];
page.on("pageerror", (e) => errors.push(String(e)));
page.on("console", (m) => m.type() === "error" && errors.push(m.text()));

for (const name of pages) {
  errors.length = 0;
  const r = await page.goto(`http://localhost:4173${base}/${name}`, { waitUntil: "networkidle" });
  await page.waitForTimeout(1000);
  const body = await page.innerText("body");
  const problems = [];
  if (r.status() !== 200) problems.push(`HTTP ${r.status()}`);
  if (/Error in Query|Binder Error|Catalog Error|Parser Error/i.test(body)) problems.push("query error on page");
  if (errors.length) problems.push(...errors.slice(0, 3));
  console.log(`${problems.length ? "FAIL" : "ok  "} /${name}`, problems.join(" | "));
  if (problems.length) failures++;
}

await browser.close();
server.close();
process.exit(failures ? 1 : 0);

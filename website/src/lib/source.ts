import fs from "node:fs";
import path from "node:path";

/**
 * Resolve a Swift source file from the repo (which lives one directory above
 * the website/ project root at build time).
 */
export function readSwiftSource(sourceFile: string): string {
  const repoRoot = path.resolve(process.cwd(), "..");
  const file = path.join(repoRoot, sourceFile);
  if (!fs.existsSync(file)) return "";
  return fs.readFileSync(file, "utf8");
}
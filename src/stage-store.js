// Browser-local stage handoff. IndexedDB avoids the small Web Storage size limit.
let connection;
function database() {
  if (!connection)
    connection = new Promise((resolve, reject) => {
      const request = indexedDB.open("digital-natives-stages", 1);
      request.onupgradeneeded = () =>
        request.result.createObjectStore("stages");
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  return connection;
}
export async function stageRecord(key, value) {
  const db = await database();
  return new Promise((resolve, reject) => {
    const write = value !== undefined,
      tx = db.transaction("stages", write ? "readwrite" : "readonly");
    const req = write
      ? tx.objectStore("stages").put(value, key)
      : tx.objectStore("stages").get(key);
    tx.oncomplete = () => resolve(req.result);
    tx.onerror = () => reject(tx.error);
    tx.onabort = () => reject(tx.error || Error("Stage storage interrupted"));
  });
}
export function workspaceId() {
  let id = sessionStorage.getItem("digital-natives-workspace");
  if (!id) {
    id = crypto.randomUUID();
    sessionStorage.setItem("digital-natives-workspace", id);
  }
  return id;
}

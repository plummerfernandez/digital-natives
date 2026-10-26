import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Mesh } from '../src/mesh.js';
import { exportGLB, exportGLTF, buildGLTF } from '../src/gltf.js';
import { parseGLTF } from '../src/gltf-import.js';
// Three's file loader also runs in Node when supplied this browser event type.
globalThis.ProgressEvent ??= class { constructor(type, data) { this.type=type; Object.assign(this,data); } };
const source = () => new Mesh([[0,0,0],[100,0,0],[0,100,0],[0,0,100]], [[0,1,2],[0,3,1]], [[128,0,255],[0,255,0]]);
const encode = j => new TextEncoder().encode(JSON.stringify(j)).buffer;
test('GLB and embedded glTF round-trip colours, units, orientation and welded topology', async()=>{
 for (const data of [exportGLB(source()), new TextEncoder().encode(exportGLTF(source())).buffer]) {
  const {mesh,warnings}=await parseGLTF(data);
  assert.equal(mesh.vertices.length,4);assert.equal(mesh.faces.length,2);
  assert.deepEqual(mesh.colors,source().colors);assert.deepEqual(warnings,[]);
  mesh.bounds().size.forEach(x=>assert.ok(Math.abs(x-100)<.0001));
  assert.ok(mesh.normal(0)[2]>.99);assert.ok(mesh.normal(1)[1]>.99);
 }
});
test('local companion buffers, scene transforms, reflected winding, material colour and cm conversion',async()=>{
 const {json,binary}=buildGLTF(source()); json.buffers[0].uri='folder/model.bin';
 json.nodes[0].translation=[1,2,3];json.nodes[0].scale=[-2,2,2];
 json.meshes[0].primitives[0].attributes.COLOR_0=undefined;
 json.materials[0].pbrMetallicRoughness.baseColorFactor=[.5,0,0,1];
 const {mesh}=await parseGLTF(encode(json),[new File([binary],'model.bin')],'cm');
 assert.deepEqual(mesh.colors,[[188,0,0],[188,0,0]]);
 const b=mesh.bounds();[80,-300,200].forEach((x,i)=>assert.ok(Math.abs(b.min[i]-x)<.0001));
 assert.ok(mesh.normal(0)[2]>.99);
 await assert.rejects(parseGLTF(encode(json)),/model.bin/);
});
test('textures omitted without fetching remote images; unsupported compression and broken GLB rejected',async()=>{
 const json=JSON.parse(exportGLTF(source()));json.images=[{uri:'https://example.invalid/image.png'}];json.textures=[{source:0}];json.materials[0].pbrMetallicRoughness.baseColorTexture={index:0};
 assert.match((await parseGLTF(encode(json))).warnings.join(' '),/Texture maps omitted/);
 json.extensionsRequired=['KHR_draco_mesh_compression'];await assert.rejects(parseGLTF(encode(json)),/uncompressed GLB/);
 await assert.rejects(parseGLTF(exportGLB(source()).slice(0,30)),/header/);
});

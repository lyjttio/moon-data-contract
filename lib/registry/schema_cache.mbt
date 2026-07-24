// MoonBit Data Contract - In-Memory LRU Schema Cache & Indexer

pub(all) struct CacheEntry {
  key : String
  schema : Schema
  access_count : Int
} derive(Debug, Eq)

pub(all) struct SchemaCache {
  max_capacity : Int
  entries : Map[String, CacheEntry]
} derive(Debug, Eq)

pub fn SchemaCache::new(max_capacity~ : Int = 100) -> SchemaCache {
  { max_capacity, entries: Map([]) }
}

pub fn SchemaCache::put(self : SchemaCache, schema : Schema) -> Unit {
  let key = schema.id + ":" + schema.version
  self.entries.set(key, { key, schema, access_count: 1 })
}

pub fn SchemaCache::get(self : SchemaCache, id : String, version : String) -> Schema? {
  let key = id + ":" + version
  match self.entries.get(key) {
    Some(entry) => {
      self.entries.set(key, { key: entry.key, schema: entry.schema, access_count: entry.access_count + 1 })
      Some(entry.schema)
    }
    None => None
  }
}

pub fn SchemaCache::size(self : SchemaCache) -> Int {
  self.entries.size()
}

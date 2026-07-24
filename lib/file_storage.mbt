// MoonBit Data Contract - File-Backed Persistent Schema Store

pub(all) struct FileStoreConfig {
  base_dir : String
  auto_create : Bool
} derive(Debug, Eq)

pub fn FileStoreConfig::new(base_dir : String) -> FileStoreConfig {
  { base_dir, auto_create: true }
}

pub fn get_schema_filepath(config : FileStoreConfig, id : String, version : String) -> String {
  config.base_dir + "/" + id + "-" + version + ".json"
}

class Migrations

  require './app/dal/database'

  def initialize
    raise 'Can\'t initialize static class'
  end
  
  def self.run_all
    create_version_table
    migrate_to_latest
  end
  
  def self.create_version_table
    Database.execute <<SQL
      CREATE TABLE IF NOT EXISTS version (
        version int,
        migrated_on datetime
      );
SQL
  end
  
  def self.migrate_to_latest
    current_version = Database.execute_scalar('SELECT MAX(version) FROM version;')
    
    # Try to make these idempotent
    if (current_version.nil? || current_version < 1) then
      Database.execute <<SQL
        CREATE TABLE IF NOT EXISTS sites (
          site_id integer PRIMARY KEY AUTOINCREMENT,
          domain varchar(255)
        );
SQL        
      Database.execute <<SQL
        CREATE TABLE IF NOT EXISTS pages (
          original_url varchar(255),
          filename varchar(255),
          as_text text
        );
SQL
      Database.execute <<SQL        
        INSERT INTO version VALUES (1, datetime());
SQL
    end
  end
end

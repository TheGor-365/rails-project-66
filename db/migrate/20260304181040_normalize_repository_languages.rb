# frozen_string_literal: true

class NormalizeRepositoryLanguages < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      UPDATE repositories
      SET language = lower(language)
      WHERE language IS NOT NULL;
    SQL
  end

  def down
    execute <<~SQL
      UPDATE repositories
      SET language = CASE lower(language)
        WHEN 'ruby' THEN 'Ruby'
        WHEN 'javascript' THEN 'JavaScript'
        ELSE language
      END
      WHERE language IS NOT NULL;
    SQL
  end
end

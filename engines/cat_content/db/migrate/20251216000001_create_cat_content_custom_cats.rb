class CreateCatContentCustomCats < ActiveRecord::Migration[7.1]
  def change
    create_table "cat_content.custom_cats", id: :uuid do |t|
      t.string :user_id, null: false
      t.string :name, null: false
      t.text :description
      t.string :visibility, null: false
      t.text :prompt_text
      t.text :story_text
      t.string :image_url
      t.string :image_alt
      t.string :tags, array: true, default: []
      t.timestamps
    end
    
    add_index "cat_content.custom_cats", :user_id
    add_index "cat_content.custom_cats", :visibility
  end
end

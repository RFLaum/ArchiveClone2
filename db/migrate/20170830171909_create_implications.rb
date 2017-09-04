class CreateImplications < ActiveRecord::Migration[5.0]
  def change
    create_table :implications do |t|
      t.string :implier
      t.string :implied
    end

    add_index :implications, %i[implier implied], unique: true
    add_index :implications, :implied
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_25_102758) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "handbags", id: :serial, force: :cascade do |t|
    t.integer "reference_no"
    t.string "image"
    t.text "name"
    t.text "website"
    t.integer "cost"
    t.string "condition"
    t.string "expert"
    t.string "collection"
    t.string "color"
    t.string "model"
    t.string "gender"
    t.string "material"
    t.integer "length"
    t.integer "height"
    t.integer "width"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prices", force: :cascade do |t|
    t.bigint "handbag_id", null: false
    t.string "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["handbag_id"], name: "index_prices_on_handbag_id"
  end

  add_foreign_key "prices", "handbags"
end

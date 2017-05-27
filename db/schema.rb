# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150318073757) do

  create_table "area_federations", force: :cascade do |t|
    t.integer  "nafd_area_id",     limit: 4
    t.boolean  "is_active",        limit: 1
    t.string   "name",             limit: 255
    t.string   "secretary",        limit: 255
    t.string   "address_1",        limit: 255
    t.string   "address_2",        limit: 255
    t.string   "address_3",        limit: 255
    t.string   "address_4",        limit: 255
    t.string   "postcode",         limit: 255
    t.string   "country",          limit: 255
    t.string   "tel",              limit: 255
    t.string   "mobile",           limit: 255
    t.string   "fax",              limit: 255
    t.string   "email",            limit: 255
    t.text     "rendered_name",    limit: 16777215
    t.text     "rendered_address", limit: 16777215
    t.text     "rendered_contact", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "area_federations", ["name"], name: "index_area_federations_on_name", using: :btree

  create_table "dbo_MemberNames", id: false, force: :cascade do |t|
    t.integer "MemberID",   limit: 4,  null: false
    t.string  "MemberName", limit: 50
    t.string  "ShortName",  limit: 15
  end

  add_index "dbo_MemberNames", ["MemberID"], name: "memberid", using: :btree
  add_index "dbo_MemberNames", ["MemberName", "ShortName"], name: "MemberName", using: :btree

  create_table "dbo_inspections", primary_key: "InspectionID", force: :cascade do |t|
    t.integer  "Gen_InspectionComments", limit: 4
    t.integer  "s_Generation",           limit: 4
    t.string   "s_Lineage",              limit: 255
    t.integer  "MemberID",               limit: 4
    t.string   "s_GUID",                 limit: 38
    t.integer  "BranchID",               limit: 4
    t.datetime "InsDate"
    t.integer  "InsContactID",           limit: 4
    t.string   "InsType",                limit: 100
    t.string   "InspectorText",          limit: 100
    t.text     "InspectionComments",     limit: 65535
    t.datetime "DecReceived"
    t.string   "XLogo",                  limit: 1,     null: false
    t.string   "XCOP",                   limit: 1,     null: false
    t.string   "XPriceListAvailable",    limit: 1,     null: false
    t.string   "XPriceListDisplay",      limit: 1,     null: false
    t.string   "XBasicFuneral",          limit: 1,     null: false
    t.string   "XPriceCostAndSpec",      limit: 1,     null: false
    t.string   "XPriceDescription",      limit: 1,     null: false
    t.string   "XPriceItemised",         limit: 1,     null: false
    t.string   "XEstimateItemised",      limit: 1,     null: false
    t.string   "XWrittenConfirmation",   limit: 1,     null: false
    t.string   "XDetailedAccount",       limit: 1,     null: false
    t.string   "Comment1",               limit: 100
    t.string   "Comment2",               limit: 100
    t.string   "Comment3",               limit: 100
    t.string   "Comment4",               limit: 100
    t.string   "Comment5",               limit: 100
    t.string   "Comment6",               limit: 100
    t.string   "Comment7",               limit: 100
    t.string   "Comment8",               limit: 100
    t.string   "Comment9",               limit: 100
    t.string   "Comment10",              limit: 100
    t.string   "Comment11",              limit: 100
    t.string   "Comment12",              limit: 100
    t.string   "Comment13",              limit: 100
    t.string   "Comment14",              limit: 100
    t.string   "Comment15",              limit: 100
    t.string   "Comment16",              limit: 100
    t.string   "Comment17",              limit: 100
    t.string   "Comment18",              limit: 100
    t.string   "Comment19",              limit: 100
    t.string   "Comment20",              limit: 100
    t.datetime "DateReExamination"
    t.string   "TypeReExamination",      limit: 100
    t.datetime "FeeReExaminationPaid"
    t.datetime "DueWrittenReply"
    t.datetime "RecdWrittenReply"
    t.string   "ReplylReason",           limit: 40
    t.integer  "ImportID",               limit: 4
    t.string   "Xfac1",                  limit: 1,     null: false
    t.string   "Xfac2",                  limit: 1,     null: false
    t.string   "Xfac3",                  limit: 1,     null: false
    t.string   "xfac4",                  limit: 1,     null: false
    t.string   "xfac5",                  limit: 1,     null: false
    t.string   "xfac6",                  limit: 1,     null: false
    t.string   "xfac7",                  limit: 1,     null: false
    t.string   "xfac8",                  limit: 1,     null: false
    t.string   "xfac9",                  limit: 1,     null: false
    t.string   "Xstationary",            limit: 1,     null: false
    t.string   "XCop2",                  limit: 1,     null: false
    t.string   "Xcertificate",           limit: 1,     null: false
    t.string   "Xownership",             limit: 1,     null: false
    t.string   "Xestimate",              limit: 1,     null: false
    t.string   "Xclients",               limit: 1,     null: false
    t.string   "Xdocumentation",         limit: 1,     null: false
    t.string   "Xlegal",                 limit: 1,     null: false
    t.string   "XAllCompliant",          limit: 1,     null: false
    t.string   "Comment21",              limit: 100
    t.string   "Comment22",              limit: 100
    t.string   "Comment23",              limit: 100
    t.string   "Comment24",              limit: 100
    t.string   "Comment25",              limit: 100
    t.string   "Comment26",              limit: 100
    t.string   "Comment27",              limit: 100
    t.string   "Comment28",              limit: 100
  end

  add_index "dbo_inspections", ["InsDate"], name: "InsDate", using: :btree
  add_index "dbo_inspections", ["MemberID", "BranchID"], name: "MemberID", using: :btree

  create_table "dbo_inspectors", id: false, force: :cascade do |t|
    t.integer "InspectorID",  limit: 4
    t.integer "s_Generation", limit: 4
    t.string  "s_Lineage",    limit: 255
    t.string  "s_GUID",       limit: 38
    t.integer "ContactID",    limit: 4
    t.string  "IsActive",     limit: 1,   null: false
    t.string  "IsPrimary",    limit: 1,   null: false
    t.string  "Who",          limit: 100
    t.integer "ImportID",     limit: 4
    t.string  "InspIsActive", limit: 1,   null: false
  end

  create_table "dbo_members", id: false, force: :cascade do |t|
    t.integer "MemberID",           limit: 4,   default: 0, null: false
    t.string  "CompanyName",        limit: 255
    t.string  "Address1",           limit: 255
    t.string  "Address2",           limit: 255
    t.string  "Address3",           limit: 100
    t.string  "Town",               limit: 255
    t.string  "County",             limit: 255
    t.string  "PostCode",           limit: 255
    t.string  "CountryCode",        limit: 255
    t.string  "Telephone",          limit: 255
    t.string  "Fax",                limit: 255
    t.string  "E-Mail",             limit: 160
    t.string  "Web",                limit: 255
    t.integer "Grade",              limit: 4
    t.integer "BranchID",           limit: 4,   default: 0, null: false
    t.boolean "ChkInspectionFail",  limit: 1
    t.boolean "IsOffice",           limit: 1
    t.string  "Paftactivity",       limit: 255
    t.string  "ShortName2",         limit: 100
    t.integer "AreaID",             limit: 4
    t.string  "Category",           limit: 100
    t.string  "NatureOfBusinessID", limit: 100
    t.string  "Keyword",            limit: 255
    t.boolean "Unmanned",           limit: 1
    t.boolean "IsActive",           limit: 1
    t.integer "InspectorID",        limit: 4
    t.boolean "IsOfficeInspection", limit: 1
  end

  create_table "local_associations", force: :cascade do |t|
    t.integer  "nafd_local_id",    limit: 4
    t.boolean  "is_active",        limit: 1
    t.string   "name",             limit: 255
    t.string   "secretary",        limit: 255
    t.string   "address_1",        limit: 255
    t.string   "address_2",        limit: 255
    t.string   "address_3",        limit: 255
    t.string   "address_4",        limit: 255
    t.string   "postcode",         limit: 255
    t.string   "country",          limit: 255
    t.string   "tel",              limit: 255
    t.string   "mobile",           limit: 255
    t.string   "fax",              limit: 255
    t.string   "email",            limit: 255
    t.text     "rendered_name",    limit: 16777215
    t.text     "rendered_address", limit: 16777215
    t.text     "rendered_contact", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "local_associations", ["name"], name: "index_local_associations_on_name", using: :btree

  create_table "members", force: :cascade do |t|
    t.integer  "member_id",            limit: 4
    t.integer  "branch_id",            limit: 4
    t.integer  "post_id",              limit: 4
    t.integer  "grade",                limit: 4
    t.integer  "area_id",              limit: 4
    t.string   "company_name",         limit: 255
    t.string   "member_name",          limit: 50
    t.string   "address_1",            limit: 255
    t.string   "address_2",            limit: 255
    t.string   "address_3",            limit: 255
    t.string   "city",                 limit: 255,   default: ""
    t.string   "region",               limit: 255,   default: ""
    t.string   "postcode",             limit: 255,   default: ""
    t.string   "country",              limit: 255
    t.string   "web_site",             limit: 255
    t.string   "email",                limit: 255
    t.string   "tel",                  limit: 255
    t.string   "fax",                  limit: 255
    t.float    "latitude",             limit: 24
    t.float    "longitude",            limit: 24
    t.string   "category",             limit: 255
    t.string   "sub_category",         limit: 255
    t.string   "keywords",             limit: 255
    t.string   "short_name",           limit: 255
    t.string   "inspector_name",       limit: 255
    t.datetime "last_inspection_on"
    t.datetime "next_inspection_on"
    t.string   "last_inspection_type", limit: 255
    t.string   "next_inspection_type", limit: 255
    t.boolean  "is_office",            limit: 1
    t.boolean  "is_unmanned",          limit: 1
    t.datetime "destroyed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_status",          limit: 255
    t.text     "data",                 limit: 65535
    t.integer  "location_confidence",  limit: 4
    t.datetime "seen_at"
  end

  add_index "members", ["category"], name: "index_members_on_category", using: :btree
  add_index "members", ["company_name"], name: "company_name", using: :btree
  add_index "members", ["grade"], name: "index_members_on_grade", using: :btree
  add_index "members", ["inspector_name"], name: "index_members_on_inspector_name", using: :btree
  add_index "members", ["keywords"], name: "index_members_on_keywords", using: :btree
  add_index "members", ["member_id"], name: "index_members_on_member_id", using: :btree
  add_index "members", ["member_name"], name: "member_name", using: :btree
  add_index "members", ["short_name"], name: "short_name", using: :btree

  create_table "supplier_members", force: :cascade do |t|
    t.integer  "member_id",        limit: 4
    t.integer  "branch_id",        limit: 4
    t.integer  "post_id",          limit: 4
    t.integer  "grade",            limit: 4
    t.integer  "area_id",          limit: 4
    t.string   "company_name",     limit: 255
    t.string   "address_1",        limit: 255
    t.string   "address_2",        limit: 255
    t.string   "address_3",        limit: 255
    t.string   "city",             limit: 255
    t.string   "region",           limit: 255
    t.string   "postcode",         limit: 255
    t.string   "country",          limit: 255
    t.string   "web_site",         limit: 255
    t.string   "email",            limit: 255
    t.string   "tel",              limit: 255
    t.string   "fax",              limit: 255
    t.string   "category",         limit: 255
    t.string   "sub_category",     limit: 255
    t.string   "short_name_2",     limit: 255
    t.text     "rendered_name",    limit: 16777215
    t.text     "rendered_contact", limit: 16777215
    t.datetime "destroyed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "seen_at"
  end

  add_index "supplier_members", ["category"], name: "index_supplier_members_on_category", using: :btree
  add_index "supplier_members", ["grade"], name: "index_supplier_members_on_grade", using: :btree
  add_index "supplier_members", ["member_id"], name: "index_supplier_members_on_member_id", using: :btree
  add_index "supplier_members", ["short_name_2"], name: "index_supplier_members_on_short_name_2", using: :btree

end

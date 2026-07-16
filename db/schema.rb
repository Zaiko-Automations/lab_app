# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_07_16_030736) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "medical_requests", force: :cascade do |t|
    t.integer "webhook_receipt_id", null: false
    t.integer "patient_id", null: false
    t.integer "requester_id", null: false
    t.string "conversation_id"
    t.string "link_conversa"
    t.string "tipo"
    t.string "status"
    t.datetime "validated_at"
    t.integer "validated_by_id"
    t.json "ai_extracted_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_medical_requests_on_conversation_id"
    t.index ["patient_id"], name: "index_medical_requests_on_patient_id"
    t.index ["requester_id"], name: "index_medical_requests_on_requester_id"
    t.index ["validated_by_id"], name: "index_medical_requests_on_validated_by_id"
    t.index ["webhook_receipt_id"], name: "index_medical_requests_on_webhook_receipt_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "nome"
    t.string "cpf"
    t.date "data_nascimento"
    t.string "telefone"
    t.boolean "whatsapp"
    t.string "id_whatsapp"
    t.string "convenio"
    t.string "plano_convenio"
    t.string "sexo_biologico"
    t.string "logradouro"
    t.string "numero"
    t.string "cep"
    t.string "bairro"
    t.string "complemento"
    t.string "cidade"
    t.string "uf"
    t.string "numero_carteira"
    t.date "data_validade_carteira"
    t.date "data_pedido_medico"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_patients_on_cpf"
  end

  create_table "requested_exams", force: :cascade do |t|
    t.integer "medical_request_id", null: false
    t.string "codigo"
    t.string "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "acuracia"
    t.index ["medical_request_id"], name: "index_requested_exams_on_medical_request_id"
  end

  create_table "requesters", force: :cascade do |t|
    t.string "nome"
    t.string "numero_conselho"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["numero_conselho"], name: "index_requesters_on_numero_conselho"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "webhook_receipts", force: :cascade do |t|
    t.json "payload"
    t.string "status"
    t.text "error_message"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "medical_requests", "patients"
  add_foreign_key "medical_requests", "requesters"
  add_foreign_key "medical_requests", "webhook_receipts"
  add_foreign_key "requested_exams", "medical_requests"
end

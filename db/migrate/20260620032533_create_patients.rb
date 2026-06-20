class CreatePatients < ActiveRecord::Migration[7.1]
  def change
    create_table :patients do |t|
      t.string :nome
      t.string :cpf
      t.date :data_nascimento
      t.string :telefone
      t.boolean :whatsapp
      t.string :id_whatsapp
      t.string :convenio
      t.string :plano_convenio
      t.string :sexo_biologico
      t.string :logradouro
      t.string :numero
      t.string :cep
      t.string :bairro
      t.string :complemento
      t.string :cidade
      t.string :uf
      t.string :numero_carteira
      t.date :data_validade_carteira
      t.date :data_pedido_medico

      t.timestamps
    end
    add_index :patients, :cpf
  end
end

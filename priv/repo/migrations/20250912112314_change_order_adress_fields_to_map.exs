defmodule Shop.Repo.Migrations.ChangeOrderAdressFieldsToMap do
  use Ecto.Migration

  def change do
    execute("""
    ALTER TABLE orders
    ALTER COLUMN shipping_address TYPE jsonb
    USING shipping_address::jsonb
    """)

    execute("""
    ALTER TABLE orders
    ALTER COLUMN billing_address TYPE jsonb
    USING billing_address::jsonb
    """)
  end
end

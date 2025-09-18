defmodule Shop.Repo.Migrations.ChangeDiscountPriceToPercentageDiscount do
  use Ecto.Migration

  def up do
    alter table(:products) do
      add :percentage_discount, :decimal, precision: 5, scale: 2
    end

    execute """
    UPDATE products
    SET percentage_discount =
      CASE
        WHEN price > 0 AND discount_price IS NOT NULL AND discount_price < price
        THEN ROUND(((price - discount_price) / price * 100), 2)
        ELSE NULL
      END
    WHERE discount_price IS NOT NULL;
    """

    alter table(:products) do
      remove :discount_price
    end
  end

  def down do
    alter table(:products) do
      add :discount_price, :decimal, precision: 10, scale: 2
    end

    execute """
    UPDATE products
    SET discount_price =
      CASE
        WHEN percentage_discount IS NOT NULL AND percentage_discount > 0 AND percentage_discount <= 100
        THEN ROUND(price - (price * percentage_discount / 100), 2)
        ELSE NULL
      END
    WHERE percentage_discount IS NOT NULL;
    """

    alter table(:products) do
      remove :percentage_discount
    end
  end
end

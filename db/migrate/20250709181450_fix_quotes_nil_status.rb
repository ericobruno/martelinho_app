class FixQuotesNilStatus < ActiveRecord::Migration[8.0]
  def up
    # Update all quotes with nil status to 'aberto'
    execute "UPDATE quotes SET status = 'aberto' WHERE status IS NULL"
  end

  def down
    # This is irreversible since we don't know which quotes originally had nil status
    # But we'll leave it empty as this is a data fix
  end
end

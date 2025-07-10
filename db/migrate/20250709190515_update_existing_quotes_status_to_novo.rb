class UpdateExistingQuotesStatusToNovo < ActiveRecord::Migration[8.0]
  def up
    # Atualizar TODOS os orçamentos no banco para status 'aberto' conforme solicitado
    execute "UPDATE quotes SET status = 'aberto'"
    
    puts "✅ Todos os orçamentos no banco atualizados para status 'aberto'"
  end
  
  def down
    # Reverter mudança se necessário - voltar para 'novo' 
    execute "UPDATE quotes SET status = 'novo'"
    
    puts "↩️ Todos os orçamentos revertidos para status 'novo'"
  end
end

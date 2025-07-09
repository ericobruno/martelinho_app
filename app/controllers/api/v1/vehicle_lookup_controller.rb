class Api::V1::VehicleLookupController < ApplicationController
  require 'net/http'
  require 'json'

  def lookup_by_plate
    plate = params[:plate]&.gsub(/[^A-Za-z0-9]/, '')&.upcase
    
    if plate.blank? || !valid_plate_format?(plate)
      render json: { error: 'Placa inválida' }, status: :bad_request
      return
    end

    begin
      # Simular consulta de API (em um ambiente real, usar APIs como FipeZap, Sinesp, etc.)
      vehicle_data = simulate_vehicle_lookup(plate)
      
      if vehicle_data
        render json: {
          success: true,
          vehicle: vehicle_data
        }
      else
        render json: {
          success: false,
          message: 'Veículo não encontrado'
        }
      end
    rescue => e
      Rails.logger.error "Erro na consulta de placa #{plate}: #{e.message}"
      render json: { error: 'Erro interno do servidor' }, status: :internal_server_error
    end
  end

  private

  def valid_plate_format?(plate)
    # Formato brasileiro: AAA9999 ou AAA9A99 (Mercosul)
    plate.match?(/^[A-Z]{3}[0-9]{4}$/) || plate.match?(/^[A-Z]{3}[0-9][A-Z][0-9]{2}$/)
  end

  def simulate_vehicle_lookup(plate)
    # Simulação de dados reais - em produção, integrar com APIs como:
    # - Sinesp (Sistema Nacional de Informações de Segurança Pública)
    # - FipeZap
    # - Consulta CNJ
    # - APIs privadas de consulta veicular
    
    sample_vehicles = [
      {
        plate: 'ABC1234',
        brand: 'Chevrolet',
        model: 'Onix',
        year: 2020,
        color: 'Branco',
        fuel: 'Flex',
        engine: '1.0',
        city: 'São Paulo',
        state: 'SP'
      },
      {
        plate: 'DEF5678',
        brand: 'Volkswagen',
        model: 'Gol',
        year: 2019,
        color: 'Prata',
        fuel: 'Flex',
        engine: '1.6',
        city: 'Rio de Janeiro',
        state: 'RJ'
      },
      {
        plate: 'GHI9012',
        brand: 'Ford',
        model: 'Ka',
        year: 2021,
        color: 'Azul',
        fuel: 'Flex',
        engine: '1.0',
        city: 'Belo Horizonte',
        state: 'MG'
      }
    ]

    # Simular encontrar veículo baseado na placa
    found_vehicle = sample_vehicles.find { |v| v[:plate] == plate }
    
    if found_vehicle
      # Tentar encontrar a marca no banco de dados
      brand = VehicleBrand.find_by('LOWER(name) = ?', found_vehicle[:brand].downcase)
      model = nil
      
      if brand
        model = VehicleModel.find_by(
          'LOWER(name) = ? AND vehicle_brand_id = ?',
          found_vehicle[:model].downcase,
          brand.id
        )
      end

      {
        plate: found_vehicle[:plate],
        brand_name: found_vehicle[:brand],
        brand_id: brand&.id,
        model_name: found_vehicle[:model],
        model_id: model&.id,
        year: found_vehicle[:year],
        color: found_vehicle[:color],
        fuel: found_vehicle[:fuel],
        engine: found_vehicle[:engine],
        city: found_vehicle[:city],
        state: found_vehicle[:state]
      }
    else
      # Para placas não encontradas na simulação, gerar dados aleatórios baseados na placa
      generate_random_vehicle_data(plate)
    end
  end

  def generate_random_vehicle_data(plate)
    brands = VehicleBrand.includes(:vehicle_models).limit(10)
    return nil if brands.empty?

    selected_brand = brands.sample
    selected_model = selected_brand.vehicle_models.sample
    return nil unless selected_model

    colors = ['Branco', 'Prata', 'Preto', 'Azul', 'Vermelho', 'Cinza', 'Bege']
    fuels = ['Flex', 'Gasolina', 'Etanol', 'Diesel']
    engines = ['1.0', '1.4', '1.6', '1.8', '2.0']
    cities = ['São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Salvador', 'Brasília', 'Fortaleza']
    states = ['SP', 'RJ', 'MG', 'BA', 'DF', 'CE']

    {
      plate: plate,
      brand_name: selected_brand.name,
      brand_id: selected_brand.id,
      model_name: selected_model.name,
      model_id: selected_model.id,
      year: rand(2010..2024),
      color: colors.sample,
      fuel: fuels.sample,
      engine: engines.sample,
      city: cities.sample,
      state: states.sample
    }
  end
end 
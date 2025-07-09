require 'net/http'
require 'json'

class VehiclePlateService
  BASE_URL = 'https://api.placas.com.br/v1'
  BACKUP_URL = 'https://apicarros.com/v1'
  
  def self.lookup_plate(plate)
    return { error: 'Placa inválida' } unless valid_plate?(plate)
    
    # Clean plate format
    clean_plate = plate.gsub(/[^A-Z0-9]/, '').upcase
    
    # Try primary API
    result = fetch_from_primary_api(clean_plate)
    return result if result[:success]
    
    # Try backup API if primary fails
    result = fetch_from_backup_api(clean_plate)
    return result if result[:success]
    
    # Try local simulation for demo purposes
    simulate_plate_data(clean_plate)
  end
  
  private
  
  def self.valid_plate?(plate)
    return false if plate.blank?
    
    clean_plate = plate.gsub(/[^A-Z0-9]/, '').upcase
    
    # Old format: ABC1234
    old_format = /^[A-Z]{3}[0-9]{4}$/
    # Mercosul format: ABC1D23
    mercosul_format = /^[A-Z]{3}[0-9][A-Z][0-9]{2}$/
    
    old_format.match?(clean_plate) || mercosul_format.match?(clean_plate)
  end
  
  def self.fetch_from_primary_api(plate)
    begin
      uri = URI("#{BASE_URL}/consulta/#{plate}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      
      request = Net::HTTP::Get.new(uri)
      request['Accept'] = 'application/json'
      
      response = http.request(request)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        format_api_response(data)
      else
        { success: false, error: 'API indisponível' }
      end
    rescue => e
      Rails.logger.error "VehiclePlateService Error: #{e.message}"
      { success: false, error: 'Erro na consulta' }
    end
  end
  
  def self.fetch_from_backup_api(plate)
    begin
      uri = URI("#{BACKUP_URL}/veiculo/#{plate}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      
      request = Net::HTTP::Get.new(uri)
      request['Content-Type'] = 'application/json'
      
      response = http.request(request)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        format_backup_response(data)
      else
        { success: false, error: 'API backup indisponível' }
      end
    rescue => e
      Rails.logger.error "VehiclePlateService Backup Error: #{e.message}"
      { success: false, error: 'Erro na consulta backup' }
    end
  end
  
  def self.simulate_plate_data(plate)
    # Simulation for demo - remove in production
    brands_and_models = {
      'VOLKSWAGEN' => ['Gol', 'Polo', 'Jetta', 'Golf', 'Passat'],
      'CHEVROLET' => ['Onix', 'Prisma', 'Cruze', 'Celta', 'Corsa'],
      'FORD' => ['Ka', 'Fiesta', 'Focus', 'EcoSport', 'Fusion'],
      'FIAT' => ['Uno', 'Palio', 'Siena', 'Argo', 'Toro'],
      'HONDA' => ['Civic', 'Fit', 'City', 'HR-V', 'CR-V'],
      'TOYOTA' => ['Corolla', 'Etios', 'Yaris', 'Hilux', 'Camry']
    }
    
    # Generate pseudo-random data based on plate
    seed = plate.sum { |char| char.ord }
    srand(seed)
    
    brand = brands_and_models.keys.sample
    model = brands_and_models[brand].sample
    year = rand(2010..2024)
    colors = ['Branco', 'Prata', 'Preto', 'Azul', 'Vermelho', 'Cinza']
    
    {
      success: true,
      data: {
        plate: format_plate_display(plate),
        brand: brand,
        model: model,
        year: year,
        color: colors.sample,
        fuel_type: ['Flex', 'Gasolina', 'Etanol', 'Diesel'].sample,
        chassis: generate_chassis(seed),
        renavam: generate_renavam(seed),
        situation: 'Regular'
      },
      source: 'simulation'
    }
  end
  
  def self.format_api_response(data)
    {
      success: true,
      data: {
        plate: data['placa'] || data['plate'],
        brand: data['marca'] || data['brand'],
        model: data['modelo'] || data['model'],
        year: data['ano'] || data['year'],
        color: data['cor'] || data['color'],
        fuel_type: data['combustivel'] || data['fuel'],
        chassis: data['chassi'] || data['chassis'],
        renavam: data['renavam'],
        situation: data['situacao'] || data['situation'] || 'Regular'
      },
      source: 'api'
    }
  end
  
  def self.format_backup_response(data)
    {
      success: true,
      data: {
        plate: data['placa'],
        brand: data['marca'],
        model: data['modelo'],
        year: data['anoModelo'],
        color: data['cor'],
        fuel_type: data['combustivel'],
        chassis: data['chassi'],
        renavam: data['renavam'],
        situation: 'Regular'
      },
      source: 'backup_api'
    }
  end
  
  def self.format_plate_display(plate)
    clean = plate.gsub(/[^A-Z0-9]/, '')
    if clean.length == 7
      if clean.match?(/^[A-Z]{3}[0-9]{4}$/)
        # Old format: ABC1234 -> ABC-1234
        "#{clean[0..2]}-#{clean[3..6]}"
      else
        # Mercosul format: ABC1D23 -> ABC1D23
        clean
      end
    else
      clean
    end
  end
  
  def self.generate_chassis(seed)
    srand(seed)
    chars = ('A'..'Z').to_a + ('0'..'9').to_a - ['I', 'O', 'Q']
    17.times.map { chars.sample }.join
  end
  
  def self.generate_renavam(seed)
    srand(seed)
    rand(100000000..999999999).to_s
  end
end 
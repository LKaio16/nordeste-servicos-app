import '../models/tour.dart';
import '../models/restaurant.dart';
import '../models/article.dart';
import '../models/point_of_interest.dart';
import '../models/tide_data.dart';
import '../models/weather_data.dart';
import '../models/nightlife_venue.dart';
import '../models/vehicle.dart';

/// Serviço com dados mockados baseados no protótipo
/// Será substituído pela integração com a API
class MockDataService {
  // Singleton
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  /// Passeios/Tours
  List<Tour> getTours() {
    return [
      Tour(
        id: 1,
        name: 'Passeio de Barco Entardecer VIP',
        description: 'Aprecie o pôr do sol mais bonito do Brasil',
        fullDescription: 'Experiência exclusiva ao entardecer com serviço de bordo premium, navegando pelas águas cristalinas de Noronha. Inclui bebidas, petiscos gourmet e paradas estratégicas para fotos inesquecíveis do pôr do sol.',
        price: 'A partir de R\$ 600',
        duration: '3 horas',
        includes: ['Bebidas premium', 'Petiscos gourmet', 'Guia especializado', 'Equipamento de snorkel'],
        imageUrl: 'https://images.unsplash.com/photo-1495954484750-af469f2f9be5',
        topSeller: 1,
        categories: [TourCategory.todos, TourCategory.aquaticos, TourCategory.exclusivos],
        featured: true,
      ),
      Tour(
        id: 2,
        name: 'Mergulho de Cilindro',
        description: 'Explore o fundo do mar com instrutores certificados',
        fullDescription: 'Mergulho profissional com instrutores PADI certificados. Explore naufrágios históricos, vida marinha abundante e formações rochosas únicas. Todo equipamento incluído e briefing completo de segurança.',
        price: 'A partir de R\$ 450',
        duration: '4 horas',
        includes: ['Equipamento completo', 'Instrutor PADI', '2 mergulhos', 'Fotos subaquáticas'],
        imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5',
        topSeller: 2,
        categories: [TourCategory.todos, TourCategory.aquaticos, TourCategory.aventura],
        featured: true,
      ),
      Tour(
        id: 3,
        name: 'Ilha Tour Privativo',
        description: 'Conheça todos os pontos turísticos com guia exclusivo',
        fullDescription: 'Tour completo da ilha com veículo privativo e guia exclusivo. Visite todas as praias principais, mirantes estratégicos e locais históricos. Totalmente personalizável de acordo com suas preferências.',
        price: 'A partir de R\$ 800',
        duration: 'Dia inteiro',
        includes: ['Veículo privativo', 'Guia exclusivo', 'Água e lanches', 'Flexibilidade total'],
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
        topSeller: 3,
        categories: [TourCategory.todos, TourCategory.terrestres, TourCategory.exclusivos],
        featured: true,
      ),
      Tour(
        id: 4,
        name: 'Passeio de Lancha Privativo',
        description: 'Experiência exclusiva pelas águas de Noronha',
        fullDescription: 'Lancha privativa para grupos de até 8 pessoas. Roteiro totalmente personalizável, incluindo paradas para mergulho, Baía dos Golfinhos e outras atrações marinhas. Serviço de bordo incluso.',
        price: 'A partir de R\$ 1.500',
        duration: '4 horas',
        includes: ['Lancha privativa', 'Comandante', 'Bebidas e petiscos', 'Equipamento snorkel'],
        imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
        categories: [TourCategory.todos, TourCategory.aquaticos, TourCategory.exclusivos],
        featured: true,
      ),
      Tour(
        id: 5,
        name: 'Trilhas Guiadas',
        description: 'Trilhas com guia local, incluindo Atalaia',
        fullDescription: 'Trilhas ecológicas com guia credenciado pelo ICMBio. Conheça a fauna e flora local, mirantes espetaculares e piscinas naturais. Inclui trilha do Atalaia (sujeito a disponibilidade).',
        price: 'A partir de R\$ 120',
        duration: '3-4 horas',
        includes: ['Guia credenciado', 'Equipamento snorkel', 'Seguro', 'Autorização ICMBio'],
        imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306',
        categories: [TourCategory.todos, TourCategory.terrestres, TourCategory.aventura],
        featured: true,
      ),
      Tour(
        id: 6,
        name: 'Canoa Havaiana',
        description: 'Remada nas águas cristalinas, observação de tartarugas e peixes',
        fullDescription: 'Atividade física e contemplação da natureza. Reme pelas águas calmas e cristalinas com instrutores experientes. Grande chance de avistar tartarugas marinhas, golfinhos e cardumes coloridos.',
        price: 'A partir de R\$ 200',
        duration: '2 horas',
        includes: ['Equipamento completo', 'Instrutor', 'Colete salva-vidas', 'Seguro'],
        imageUrl: 'https://images.unsplash.com/photo-1502933691298-84fc14542831',
        categories: [TourCategory.todos, TourCategory.aquaticos, TourCategory.aventura],
      ),
      Tour(
        id: 7,
        name: 'Ilha Tour Coletivo',
        description: 'Tour guiado pelos principais pontos da ilha',
        fullDescription: 'Tour compartilhado em grupo pelos pontos turísticos mais importantes de Fernando de Noronha. Guia profissional, transporte confortável e paradas estratégicas para fotos e banho de mar.',
        price: 'A partir de R\$ 150',
        duration: '6 horas',
        includes: ['Transporte compartilhado', 'Guia profissional', 'Entrada em praias', 'Água'],
        imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1',
        categories: [TourCategory.todos, TourCategory.terrestres],
      ),
      Tour(
        id: 8,
        name: 'Passeio de Barco Tradicional',
        description: 'Navegue pelas baías mais bonitas de Noronha',
        fullDescription: 'Passeio de barco clássico pelas principais baías da ilha. Paradas para snorkel, observação da vida marinha e contemplação das paisagens paradisíacas. Ambiente descontraído e familiar.',
        price: 'A partir de R\$ 250',
        duration: '3 horas',
        includes: ['Barco tradicional', 'Tripulação', 'Snorkel', 'Bebidas'],
        imageUrl: 'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c',
        categories: [TourCategory.todos, TourCategory.aquaticos],
      ),
      Tour(
        id: 9,
        name: 'Ensaio Fotográfico',
        description: 'Registre momentos únicos com fotógrafo profissional',
        fullDescription: 'Ensaio fotográfico profissional nos cenários mais deslumbrantes de Noronha. Fotógrafo especializado em registros de viagem, lua de mel e famílias. Todas as fotos editadas e entregues em alta resolução.',
        price: 'A partir de R\$ 900',
        duration: '2-3 horas',
        includes: ['Fotógrafo profissional', 'Edição completa', 'Mínimo 100 fotos', 'Galeria online'],
        imageUrl: 'https://images.unsplash.com/photo-1452421822248-d4c2b47f0c81',
        categories: [TourCategory.todos, TourCategory.exclusivos],
      ),
    ];
  }

  /// Restaurantes
  List<Restaurant> getRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'Restaurante Mergulhão',
        description: 'Especializado em peixes e frutos do mar frescos',
        whatsapp: '5581999999999',
        phone: '(81) 3619-1234',
        imageUrl: 'https://images.unsplash.com/photo-1559339352-11d035aa65de',
        hasReservation: true,
        hasDelivery: false,
        priceRange: '\$\$\$\$',
      ),
      Restaurant(
        id: '2',
        name: 'Xica da Silva',
        description: 'Culinária nordestina autêntica com vista privilegiada',
        whatsapp: '5581999999999',
        phone: '(81) 3619-1235',
        imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
        hasReservation: true,
        hasDelivery: false,
        priceRange: '\$\$\$',
      ),
      Restaurant(
        id: '3',
        name: 'Pizzaria Noronha',
        description: 'Pizzas artesanais e massas caseiras com delivery',
        whatsapp: '5581999999999',
        phone: '(81) 3619-1236',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
        hasReservation: false,
        hasDelivery: true,
        priceRange: '\$\$',
      ),
      Restaurant(
        id: '4',
        name: 'Lanchonete da Praça',
        description: 'Lanches rápidos e porções variadas para delivery',
        whatsapp: '5581999999999',
        phone: '(81) 3619-1237',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
        hasReservation: false,
        hasDelivery: true,
        priceRange: '\$',
      ),
      Restaurant(
        id: '5',
        name: 'Cacimba Bistrô',
        description: 'Gastronomia contemporânea com ingredientes locais frescos',
        whatsapp: '5581999999999',
        phone: '(81) 3619-1238',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
        hasReservation: true,
        hasDelivery: false,
        priceRange: '\$\$\$\$',
      ),
      Restaurant(
        id: '6',
        name: 'Bar do Meio',
        description: 'O melhor pôr do sol com petiscos especiais e drinks',
        whatsapp: '5581999999999',
        phone: '(81) 3619-1239',
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
        hasReservation: true,
        hasDelivery: false,
        priceRange: '\$\$\$',
      ),
    ];
  }

  /// Pontos de interesse
  List<PointOfInterest> getPointsOfInterest() {
    return [
      PointOfInterest(id: '1', name: 'Baía do Sancho', type: 'Praia', coords: 'Mar de Dentro'),
      PointOfInterest(id: '2', name: 'Baía dos Porcos', type: 'Praia', coords: 'Mar de Dentro'),
      PointOfInterest(id: '3', name: 'Praia do Leão', type: 'Praia', coords: 'Mar de Fora'),
      PointOfInterest(id: '4', name: 'Cacimba do Padre', type: 'Praia', coords: 'Mar de Fora'),
      PointOfInterest(id: '5', name: 'Vila dos Remédios', type: 'Centro', coords: 'Principal'),
      PointOfInterest(id: '6', name: 'Mirante dos Golfinhos', type: 'Mirante', coords: 'Mar de Dentro'),
      PointOfInterest(id: '7', name: 'Forte Nossa Senhora', type: 'Histórico', coords: 'Vila dos Remédios'),
      PointOfInterest(id: '8', name: 'Piscina Natural do Atalaia', type: 'Piscina Natural', coords: 'Mar de Dentro'),
    ];
  }

  /// Dados de maré (mock)
  List<TideData> getTideData(DateTime date) {
    return [
      TideData(time: '03:45', height: '2.8m', type: TideType.high),
      TideData(time: '09:30', height: '0.4m', type: TideType.low),
      TideData(time: '16:15', height: '2.6m', type: TideType.high),
      TideData(time: '22:00', height: '0.6m', type: TideType.low),
    ];
  }

  /// Dados do clima (mock)
  CurrentWeather getCurrentWeather() {
    return CurrentWeather(
      temp: 28,
      condition: 'Parcialmente Nublado',
      humidity: 75,
      wind: 18,
      uvIndex: 8,
      seaCondition: 'Calmo',
      feelsLike: 31,
    );
  }

  List<HourlyWeather> getHourlyWeather(DateTime date) {
    return [
      HourlyWeather(time: '00:00', temp: '24°', icon: WeatherIcon.cloud, rain: '10%'),
      HourlyWeather(time: '03:00', temp: '23°', icon: WeatherIcon.cloud, rain: '5%'),
      HourlyWeather(time: '06:00', temp: '24°', icon: WeatherIcon.sun, rain: '0%'),
      HourlyWeather(time: '09:00', temp: '27°', icon: WeatherIcon.sun, rain: '5%'),
      HourlyWeather(time: '12:00', temp: '29°', icon: WeatherIcon.cloud, rain: '10%'),
      HourlyWeather(time: '15:00', temp: '28°', icon: WeatherIcon.cloud, rain: '20%'),
      HourlyWeather(time: '18:00', temp: '26°', icon: WeatherIcon.cloud, rain: '10%'),
      HourlyWeather(time: '21:00', temp: '25°', icon: WeatherIcon.cloud, rain: '10%'),
    ];
  }

  List<DailyForecast> getDailyForecast() {
    return [
      DailyForecast(day: 'Seg', temp: '27°', icon: WeatherIcon.sun, rain: '10%'),
      DailyForecast(day: 'Ter', temp: '28°', icon: WeatherIcon.cloud, rain: '20%'),
      DailyForecast(day: 'Qua', temp: '29°', icon: WeatherIcon.sun, rain: '5%'),
      DailyForecast(day: 'Qui', temp: '27°', icon: WeatherIcon.rain, rain: '60%'),
      DailyForecast(day: 'Sex', temp: '26°', icon: WeatherIcon.cloud, rain: '30%'),
      DailyForecast(day: 'Sáb', temp: '28°', icon: WeatherIcon.sun, rain: '15%'),
      DailyForecast(day: 'Dom', temp: '29°', icon: WeatherIcon.sun, rain: '10%'),
    ];
  }

  /// Vida noturna
  List<NightlifeVenue> getNightlifeVenues() {
    return [
      NightlifeVenue(
        id: '1',
        name: 'Bar do Cachorro',
        description: 'O mais famoso bar da ilha com música ao vivo e clima descontraído',
        type: 'Bar e Música Ao Vivo',
        schedule: 'Qui a Sáb: 19h - 02h',
        highlight: 'Quinta: Samba e Pagode',
        imageUrl: 'https://images.unsplash.com/photo-1546484458-6904289cd4f0',
        rating: 4.8,
        whatsapp: '5581999999999',
      ),
      NightlifeVenue(
        id: '2',
        name: 'Bar do Meio',
        description: 'Local perfeito para apreciar o pôr do sol com MPB e música ao vivo',
        type: 'Bar Sunset',
        schedule: 'Qua, Sáb e Dom: 17h - 23h',
        highlight: 'Quarta: Pôr do Sol e MPB',
        imageUrl: 'https://images.unsplash.com/photo-1682629906883-76eaa5e03693',
        rating: 4.7,
        whatsapp: '5581999999999',
      ),
      NightlifeVenue(
        id: '3',
        name: 'Cacimba Sunset',
        description: 'Música eletrônica e DJ ao pôr do sol na Praia da Cacimba',
        type: 'Beach Club',
        schedule: 'Sexta: 17h - 21h',
        highlight: 'DJ e Eletrônica',
        imageUrl: 'https://images.unsplash.com/photo-1733411683500-50f83ca70a1b',
        rating: 4.9,
        whatsapp: '5581999999999',
      ),
      NightlifeVenue(
        id: '4',
        name: 'Forró na Vila',
        description: 'Forró tradicional no coração da Vila dos Remédios',
        type: 'Forró',
        schedule: 'Terça: 20h - 23h',
        highlight: 'Forró Pé de Serra',
        imageUrl: 'https://images.unsplash.com/photo-1632522497086-583f8cfec267',
        rating: 4.6,
        whatsapp: '5581999999999',
      ),
    ];
  }

  /// Veículos para aluguel
  List<Vehicle> getVehicles() {
    return [
      Vehicle(
        id: '1',
        name: 'Bicicleta Elétrica',
        icon: '🚲',
        price: 'R\$ 100/dia',
        imageUrl: 'https://images.unsplash.com/photo-1571068316344-75bc76f77890',
        features: ['Ideal para distâncias curtas', 'Ecológico', 'Fácil estacionamento'],
      ),
      Vehicle(
        id: '2',
        name: 'Moto',
        icon: '🏍️',
        price: 'R\$ 150 - 250/dia',
        imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
        features: ['Ágil no trânsito', 'Econômico', 'CNH categoria A obrigatória'],
      ),
      Vehicle(
        id: '3',
        name: 'Buggy',
        icon: '🚙',
        price: 'R\$ 250 - 400/dia',
        imageUrl: 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d',
        features: ['Experiência única', 'Ideal para praias', 'Comporta 4 pessoas'],
      ),
    ];
  }

  /// Carros para aluguel
  List<CarRental> getCarRentals() {
    return [
      CarRental(
        id: '1',
        category: 'Grupo Intermediário',
        models: 'Duster, Jimmy, Oroch, Creta ou Pajero TR4',
        pricePix: 'R\$ 700',
        priceCard: 'R\$ 780',
        installments: 'até 3x',
      ),
      CarRental(
        id: '2',
        category: 'Grupo Especial',
        models: 'Jeep Renegade ou Mitsubishi L200',
        pricePix: 'R\$ 850',
        priceCard: 'R\$ 945',
        installments: 'até 3x',
      ),
      CarRental(
        id: '3',
        category: 'Grupo Executivo',
        models: 'SW4 ou TrailBlazer',
        pricePix: 'R\$ 980',
        priceCard: 'R\$ 1.090',
        installments: 'até 3x',
      ),
    ];
  }

  /// Locais de transporte
  List<String> getTransportLocations() {
    return [
      'Aeroporto',
      'Vila dos Remédios',
      'Floresta Nova',
      'Boldró',
      'Sueste',
      'Baía do Sancho',
      'Praia do Leão',
      'Cacimba do Padre',
      'Porto',
    ];
  }

  /// Calcular preço de táxi
  Map<String, int> getTaxiPrice(String origin, String destination) {
    // Preços base mockados
    final basePrices = {
      'Aeroporto-Vila dos Remédios': 35,
      'Vila dos Remédios-Baía do Sancho': 45,
      'Aeroporto-Boldró': 40,
      'Vila dos Remédios-Praia do Leão': 50,
      'Floresta Nova-Cacimba do Padre': 35,
    };

    final key = '$origin-$destination';
    final reverseKey = '$destination-$origin';

    final basePrice = basePrices[key] ?? basePrices[reverseKey] ?? 40;

    return {
      'tarifa1': basePrice,
      'tarifa2': (basePrice * 1.5).round(),
    };
  }

  /// Pontos de ônibus
  List<Map<String, dynamic>> getBusStops() {
    return [
      {'name': 'Aeroporto', 'time': '07:00'},
      {'name': 'Vila dos Remédios', 'time': '07:15'},
      {'name': 'Floresta Nova', 'time': '07:25'},
      {'name': 'Sueste', 'time': '07:40'},
    ];
  }

  /// Cidades para calculadora de viagem
  List<String> getCities() {
    return [
      'São Paulo - SP',
      'Rio de Janeiro - RJ',
      'Brasília - DF',
      'Belo Horizonte - MG',
      'Fortaleza - CE',
      'Salvador - BA',
      'Recife - PE',
      'Curitiba - PR',
      'Porto Alegre - RS',
      'Manaus - AM',
      'Goiânia - GO',
      'Belém - PA',
      'Natal - RN',
      'Florianópolis - SC',
      'João Pessoa - PB',
      'Campinas - SP',
      'Vitória - ES',
      'Maceió - AL',
      'Aracaju - SE',
      'São Luís - MA',
    ];
  }

  /// Lista de passeios para calculadora
  List<Map<String, dynamic>> getCalculatorTours() {
    return [
      {'name': 'Passeio de Barco Entardecer VIP', 'price': 600, 'description': 'Pôr do sol inesquecível'},
      {'name': 'Mergulho de Cilindro', 'price': 450, 'description': 'Com instrutor PADI'},
      {'name': 'Ilha Tour Privativo', 'price': 800, 'description': 'Guia exclusivo'},
      {'name': 'Passeio de Lancha Privativo', 'price': 1500, 'description': 'Até 8 pessoas'},
      {'name': 'Canoa Havaiana', 'price': 200, 'description': 'Experiência única'},
      {'name': 'Trilhas Guiadas', 'price': 120, 'description': 'Inclui Atalaia'},
      {'name': 'Planasub', 'price': 280, 'description': 'Aventura submarina'},
      {'name': 'Aquasub', 'price': 350, 'description': 'Scooter subaquático'},
    ];
  }
}







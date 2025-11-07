// Mock data for demonstration purposes when API is not accessible
const mockPokemonCards = [
  {
    'id': 'base1-4',
    'name': 'Charizard',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/4_hires.png',
      'small': 'https://images.pokemontcg.io/base1/4.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare Holo',
    'evolvesFrom': 'Charmeleon',
    'nationalPokedexNumbers': [6],
    'supertype': 'Pokémon',
    'subtypes': ['Stage 2']
  },
  {
    'id': 'base1-1',
    'name': 'Alakazam',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/1_hires.png',
      'small': 'https://images.pokemontcg.io/base1/1.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare Holo',
    'evolvesFrom': 'Kadabra',
    'nationalPokedexNumbers': [65],
    'supertype': 'Pokémon',
    'subtypes': ['Stage 2']
  },
  {
    'id': 'base1-25',
    'name': 'Pikachu',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/58_hires.png',
      'small': 'https://images.pokemontcg.io/base1/58.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Common',
    'nationalPokedexNumbers': [25],
    'supertype': 'Pokémon',
    'subtypes': ['Basic']
  },
  {
    'id': 'base1-150',
    'name': 'Mewtwo',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/10_hires.png',
      'small': 'https://images.pokemontcg.io/base1/10.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare Holo',
    'nationalPokedexNumbers': [150],
    'supertype': 'Pokémon',
    'subtypes': ['Basic']
  },
  {
    'id': 'base1-9',
    'name': 'Blastoise',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/2_hires.png',
      'small': 'https://images.pokemontcg.io/base1/2.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare Holo',
    'evolvesFrom': 'Wartortle',
    'nationalPokedexNumbers': [9],
    'supertype': 'Pokémon',
    'subtypes': ['Stage 2']
  },
  {
    'id': 'base1-3',
    'name': 'Venusaur',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/15_hires.png',
      'small': 'https://images.pokemontcg.io/base1/15.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare Holo',
    'evolvesFrom': 'Ivysaur',
    'nationalPokedexNumbers': [3],
    'supertype': 'Pokémon',
    'subtypes': ['Stage 2']
  },
  {
    'id': 'base1-144',
    'name': 'Articuno',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/17_hires.png',
      'small': 'https://images.pokemontcg.io/base1/17.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare Holo',
    'nationalPokedexNumbers': [144],
    'supertype': 'Pokémon',
    'subtypes': ['Basic']
  },
  {
    'id': 'base1-145',
    'name': 'Zapdos',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/16_hires.png',
      'small': 'https://images.pokemontcg.io/base1/16.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare Holo',
    'nationalPokedexNumbers': [145],
    'supertype': 'Pokémon',
    'subtypes': ['Basic']
  },
  {
    'id': 'base1-146',
    'name': 'Moltres',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/12_hires.png',
      'small': 'https://images.pokemontcg.io/base1/12.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare Holo',
    'nationalPokedexNumbers': [146],
    'supertype': 'Pokémon',
    'subtypes': ['Basic']
  },
  {
    'id': 'base1-151',
    'name': 'Mew',
    'images': {
      'large': 'https://images.pokemontcg.io/base1/23_hires.png',
      'small': 'https://images.pokemontcg.io/base1/23.png'
    },
    'set': {'name': 'Base'},
    'rarity': 'Rare',
    'nationalPokedexNumbers': [151],
    'supertype': 'Pokémon',
    'subtypes': ['Basic']
  }
];

const mockApiResponse = {
  'data': mockPokemonCards,
  'page': 1,
  'pageSize': 250,
  'count': 10,
  'totalCount': 10
};

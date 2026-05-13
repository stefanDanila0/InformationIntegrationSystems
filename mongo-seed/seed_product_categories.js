// Seed product categories into MongoDB for DSA-NoSQL-MongoDBService
// This creates a collection matching the DepartamentsCities pattern:
// a single document with an array of category objects

db = db.getSiblingDB('olist_mongo');

db.ProductCategories.drop();

db.ProductCategories.insertOne({
   "categories": [
      { "categoryName": "beleza_saude",            "categoryNameEnglish": "health_beauty" },
      { "categoryName": "informatica_acessorios",   "categoryNameEnglish": "computers_accessories" },
      { "categoryName": "automotivo",               "categoryNameEnglish": "auto" },
      { "categoryName": "cama_mesa_banho",          "categoryNameEnglish": "bed_bath_table" },
      { "categoryName": "moveis_decoracao",         "categoryNameEnglish": "furniture_decor" },
      { "categoryName": "esporte_lazer",            "categoryNameEnglish": "sports_leisure" },
      { "categoryName": "perfumaria",               "categoryNameEnglish": "perfumery" },
      { "categoryName": "utilidades_domesticas",    "categoryNameEnglish": "housewares" },
      { "categoryName": "telefonia",                "categoryNameEnglish": "telephony" },
      { "categoryName": "relogios_presentes",       "categoryNameEnglish": "watches_gifts" },
      { "categoryName": "alimentos_bebidas",        "categoryNameEnglish": "food_drink" },
      { "categoryName": "bebes",                    "categoryNameEnglish": "baby" },
      { "categoryName": "papelaria",                "categoryNameEnglish": "stationery" },
      { "categoryName": "tablets_impressao_imagem", "categoryNameEnglish": "tablets_printing_image" },
      { "categoryName": "brinquedos",               "categoryNameEnglish": "toys" },
      { "categoryName": "ferramentas_jardim",       "categoryNameEnglish": "garden_tools" },
      { "categoryName": "fashion_bolsas_e_acessorios", "categoryNameEnglish": "fashion_bags_accessories" },
      { "categoryName": "cool_stuff",               "categoryNameEnglish": "cool_stuff" },
      { "categoryName": "moveis_escritorio",        "categoryNameEnglish": "office_furniture" },
      { "categoryName": "construcao_ferramentas_construcao", "categoryNameEnglish": "construction_tools_construction" },
      { "categoryName": "eletronicos",              "categoryNameEnglish": "electronics" },
      { "categoryName": "instrumentos_musicais",    "categoryNameEnglish": "musical_instruments" },
      { "categoryName": "pet_shop",                 "categoryNameEnglish": "pet_shop" },
      { "categoryName": "industria_comercio_e_negocios", "categoryNameEnglish": "industry_commerce_and_business" },
      { "categoryName": "livros_interesse_geral",   "categoryNameEnglish": "books_general_interest" },
      { "categoryName": "consoles_games",           "categoryNameEnglish": "consoles_games" },
      { "categoryName": "artigos_de_festas",        "categoryNameEnglish": "party_supplies" },
      { "categoryName": "sinalizacao_e_seguranca",  "categoryNameEnglish": "signaling_and_security" },
      { "categoryName": "pcs",                      "categoryNameEnglish": "computers" },
      { "categoryName": "artigos_de_natal",         "categoryNameEnglish": "christmas_supplies" },
      { "categoryName": "fashion_roupa_masculina",  "categoryNameEnglish": "fashion_male_clothing" },
      { "categoryName": "eletrodomesticos",         "categoryNameEnglish": "small_appliances" },
      { "categoryName": "agro_industria_e_comercio","categoryNameEnglish": "agro_industry_and_commerce" },
      { "categoryName": "moveis_sala",              "categoryNameEnglish": "furniture_living_room" },
      { "categoryName": "climatizacao",             "categoryNameEnglish": "air_conditioning" },
      { "categoryName": "construcao_ferramentas_iluminacao", "categoryNameEnglish": "construction_tools_lights" },
      { "categoryName": "flores",                   "categoryNameEnglish": "flowers" },
      { "categoryName": "livros_tecnicos",          "categoryNameEnglish": "books_technical" },
      { "categoryName": "fashion_underwear_e_moda_praia", "categoryNameEnglish": "fashion_underwear_beach" },
      { "categoryName": "fashion_calcados",         "categoryNameEnglish": "fashion_shoes" },
      { "categoryName": "audio",                    "categoryNameEnglish": "audio" },
      { "categoryName": "cds_dvds_musicais",        "categoryNameEnglish": "cds_dvds_musicals" },
      { "categoryName": "dvds_blu_ray",             "categoryNameEnglish": "dvds_blu_ray" },
      { "categoryName": "artes",                    "categoryNameEnglish": "arts" },
      { "categoryName": "malas_acessorios",         "categoryNameEnglish": "luggage_accessories" },
      { "categoryName": "casa_conforto",            "categoryNameEnglish": "home_comfort" },
      { "categoryName": "casa_construcao",          "categoryNameEnglish": "home_construction" },
      { "categoryName": "alimentos",                "categoryNameEnglish": "food" },
      { "categoryName": "musica",                   "categoryNameEnglish": "music" },
      { "categoryName": "fashion_esporte",          "categoryNameEnglish": "fashion_sport" },
      { "categoryName": "la_cuisine",               "categoryNameEnglish": "la_cuisine" },
      { "categoryName": "market_place",             "categoryNameEnglish": "market_place" },
      { "categoryName": "moveis_quarto",            "categoryNameEnglish": "furniture_bedroom" },
      { "categoryName": "moveis_cozinha_area_de_servico_jantar_e_jardim", "categoryNameEnglish": "kitchen_dining_laundry_garden_furniture" },
      { "categoryName": "construcao_ferramentas_jardim", "categoryNameEnglish": "construction_tools_garden" },
      { "categoryName": "livros_importados",        "categoryNameEnglish": "books_imported" },
      { "categoryName": "bebidas",                  "categoryNameEnglish": "drinks" },
      { "categoryName": "construcao_ferramentas_seguranca", "categoryNameEnglish": "construction_tools_safety" },
      { "categoryName": "fashion_roupa_feminina",   "categoryNameEnglish": "fashion_female_clothing" },
      { "categoryName": "fashion_roupa_infanto_juvenil", "categoryNameEnglish": "fashion_childrens_clothes" },
      { "categoryName": "eletrodomesticos_2",       "categoryNameEnglish": "small_appliances_home_oven_and_coffee" },
      { "categoryName": "casa_conforto_2",          "categoryNameEnglish": "home_comfort_2" },
      { "categoryName": "portateis_cozinha_e_preparadores_de_alimentos", "categoryNameEnglish": "portable_kitchen_food_processors" },
      { "categoryName": "pc_gamer",                 "categoryNameEnglish": "pc_gamer" },
      { "categoryName": "seguros_e_servicos",       "categoryNameEnglish": "security_and_services" },
      { "categoryName": "fraldas_higiene",          "categoryNameEnglish": "diapers_and_hygiene" },
      { "categoryName": "artes_e_artesanato",       "categoryNameEnglish": "arts_and_craftmanship" }
   ]
});

print("Product categories seeded successfully!");
print("Count: " + db.ProductCategories.countDocuments());

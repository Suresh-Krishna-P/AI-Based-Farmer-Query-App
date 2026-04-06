# AI-Based Farmer Query Support and Advisory System

A comprehensive Flutter application that provides AI-powered agricultural support and advisory services for farmers using Retrieval-Augmented Generation (RAG) technology.

## Features

### 🌾 Multi-Modal Search
- **Text Search**: Type your agricultural queries for instant answers
- **Voice Search**: Speak your questions in Hindi or English
- **Image Search**: Upload photos of crops, soil, or pests for AI analysis

### 🤖 AI-Powered Advisory
- Personalized crop management recommendations
- Pest and disease identification and treatment
- Soil health analysis and improvement suggestions
- Fertilization and irrigation guidance

### 📚 Comprehensive Knowledge Base
- **Crop diseases database** with symptoms and treatments
- **Pest management strategies** with integrated pest management (IPM)
- **Soil management practices** for different soil types
- **Best practices** for various crops and seasons
- **External Dataset Integration** with real-time data from:
  - **USDA** (Crop yield and nutritional data)
  - **FAO** (Global agricultural statistics and pest information)
  - **OpenWeather** (Weather data for agricultural planning)
  - **SoilGrids** (Global soil mapping and analysis)
  - **Agmarknet** (Market prices and agricultural commodity data)

## Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.x with Material Design
- **State Management**: Provider
- **Navigation**: Built-in Navigator 2.0
- **UI Components**: Custom widgets with responsive design

### Backend Services
- **RAG System**: Retrieval-Augmented Generation using aggressive pattern matching against our offline datasets
- **Wikipedia Oracle**: Custom integration polling the Wikipedia Global API for real-time answers (Zero API keys required)
- **Speech Recognition**: On-Device Native Speech-to-Text for voice queries
- **Image Analysis**: Local heuristic-based Computer Vision for crop/soil analysis

### Data Management
- **Local Storage**: SQLite for offline functionality
- **Datasets**: Massive, mathematically precise offline agricultural knowledge bases
- **Caching**: Efficient data retrieval and persistent storage

## Installation

### Prerequisites
- Flutter SDK 3.0 or higher
- Android Studio or VS Code with Flutter extension
- Internet connection for API calls

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd ai-based-farmer-query-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **(Optional) Configure API Keys:**
   The application operates robustly offline and utilizes a free Wikipedia Fallback. However, if you wish to use enhanced OpenAI features, create a `.env` file:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                          # Application entry point
├── models/                           # Data models
│   ├── advisory_model.dart           # Advisory system model
│   └── query_model.dart              # Query system model
├── services/                         # Business logic and API calls
│   ├── rag_service.dart              # RAG system implementation
│   ├── ai_service.dart               # AI integration service
│   ├── text_search_service.dart      # Text search functionality
│   ├── voice_search_service.dart     # Voice search functionality
│   └── image_search_service.dart     # Image search functionality
├── ui/                              # User interface components
│   ├── screens/                     # Main application screens
│   │   ├── home_screen.dart         # Main dashboard
│   │   ├── text_search_screen.dart  # Text search interface
│   │   ├── voice_search_screen.dart # Voice search interface
│   │   ├── image_search_screen.dart # Image search interface
│   │   └── advisory_screen.dart     # Advisory system interface
│   └── widgets/                     # Reusable UI components
│       ├── search_option_card.dart  # Search method cards
│       ├── search_result_item.dart  # Search result display
│       ├── advisory_card.dart       # Advisory item display
│       └── loading_indicator.dart   # Loading animations
└── datasets/                        # Agricultural knowledge bases
    ├── crop_diseases_dataset.dart   # Crop disease information
    ├── pest_management_dataset.dart # Pest control strategies
    └── soil_management_dataset.dart # Soil management practices
```

## Usage

### Text Search
1. Navigate to the Text Search screen
2. Type your agricultural query in the search bar
3. View relevant results from the knowledge base
4. Get AI-generated responses for complex queries

### Voice Search
1. Go to the Voice Search screen
2. Tap the microphone button to start recording
3. Speak your query clearly
4. The app will transcribe and search for relevant information
5. View results and recommendations

### Image Search
1. Access the Image Search screen
2. Choose to upload from gallery or take a photo
3. The AI will analyze the image for:
   - Crop diseases
   - Pest infestations
   - Soil conditions
   - General crop health
4. Receive detailed analysis and recommendations

### Advisory System
1. Visit the Advisory screen
2. Filter advisories by crop type and season
3. View personalized recommendations
4. Generate new advisories based on your specific needs

## Configuration

### Live Wikipedia & AI Integration
The application strictly relies on **Zero API Key** architectures by default! It achieves open-ended knowledge generation by parsing global agricultural parameters asynchronously from the public **Wikipedia Sandbox**.

If you wish to augment the native intelligence, the application integrates with OpenAI's GPT-3.5 Turbo API for enhanced structuring:
1. Obtain an API key from [OpenAI](https://platform.openai.com/api-keys)
2. Add it to your `.env` file
3. The RAG system will automatically transition to using this for AI-generated responses

### Dataset Customization
The application includes comprehensive datasets for:
- Crop diseases and their management
- Pest identification and control methods
- Soil types and management practices

These can be extended or modified in the `datasets/` directory.

## Contributing

We welcome contributions to improve this application! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Enhancements

- [x] Massive Offline Datasets and Metrics
- [x] Limitless API-Free Fallback System
- [ ] Multi-language support beyond Hindi and English
- [x] Weather integration for crop planning
- [x] Market price information for crops
- [ ] Community forum for farmer discussions
- [ ] Integration with agricultural extension services
- [ ] Mobile app for agricultural experts

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in this repository
- Contact the development team
- Visit our documentation

## Acknowledgments

- OpenAI for the GPT API
- Flutter community for excellent tools and libraries
- Agricultural experts who contributed to the knowledge base
- Farmers who inspired this project

---

**Note**: This application is designed to assist farmers with agricultural decisions. Always consult with local agricultural experts for region-specific advice.
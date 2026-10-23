# SmartGPS - ប្រព័ន្ធ GPS និងវាស់ដី

SmartGPS គឺជាប្រព័ន្ធពេញលេញសម្រាប់វាស់ទីតាំង, វាស់ដី, ចាប់សញ្ញា GPS និងភ្ជាប់/បញ្ជាទូរសព្ទផ្សេងទៀត។ គាំទ្រ Android និង iOS, ភាសាខ្មែរ និងអង់គ្លេស។

## 📋 មាតិកា

- [មុខងារសំខាន់](#មុខងារសំខាន់)
- [បច្ចេកវិទ្យាប្រើប្រាស់](#បច្ចេកវិទ្យាប្រើប្រាស់)
- [រចនាសម្ព័ន្ធគម្រោង](#រចនាសម្ព័ន្ធគម្រោង)
- [ការតម្លើង និងដំណើរការ](#ការតម្លើង-និងដំណើរការ)
- [API Documentation](#api-documentation)
- [ការ Deploy](#ការ-deploy)
- [ការធ្វើតេស្ត](#ការធ្វើតេស្ត)

## 🎯 មុខងារសំខាន់

### 📱 កម្មវិធីទូរសព្ទ (Mobile App)

1. **ទីតាំងបច្ចុប្បន្ន**
   - បង្ហាញ Latitude/Longitude, Altitude, Speed, Heading, Accuracy
   - Real-time location tracking លើផែនទី
   - ស្ថានភាពសញ្ញា GPS ជាក្រាហ្វិក

2. **វាស់ដី (Land Measurement)**
   - វាស់តាមការដើរ (Walk mode) ឬចុចចំណុចលើផែនទី (Tap mode)
   - គណនាក្រឡាផ្ទៃ: m², ហិកតា, អា, សង់ទីអា
   - គណនាបរិមាត្រ និងចម្ងាយរវាងចំណុច
   - រក្សាទុក Project ជាមួយឈ្មោះ, កំណត់ចំណាំ, រូបថត

3. **Waypoint & Route**
   - ចំណាំទីតាំងសំខាន់ៗ
   - កត់ត្រាផ្លូវដើរ (Track recording)
   - មើលប្រវត្តិ

4. **បំលែងកូអរដោនេ**
   - WGS84 ↔ UTM (Zone 48N)
   - DMS ↔ Decimal Degrees

5. **ភ្ជាប់ទូរសព្ទផ្សេងទៀត**
   - ភ្ជាប់តាម QR Code ឬ Pairing Code
   - មើលទីតាំង Real-time របស់ទូរសព្ទដែលបានភ្ជាប់
   - បញ្ជាពីចម្ងាយ (ដោយមានការអនុញ្ញាត)
   - Geofence និងជូនដំណឹង
   - ប៊ូតុង SOS

6. **Export/Share**
   - GeoJSON, KML, GPX, CSV
   - PDF Report ជាមួយផែនទី

### 🖥️ Backend API

- RESTful API ជាមួយ Swagger Documentation
- WebSocket សម្រាប់ Real-time tracking
- Authentication (JWT + Refresh Token, Google Sign-In, OTP)
- PostgreSQL + PostGIS សម្រាប់ Spatial queries
- Redis សម្រាប់ Cache និង Pub/Sub
- MinIO សម្រាប់ File storage

### 🎛️ Admin Dashboard

- គ្រប់គ្រងអ្នកប្រើប្រាស់
- គ្រប់គ្រងឧបករណ៍
- មើល Live tracking
- របាយការណ៍ និងស្ថិតិ

## 🛠️ បច្ចេកវិទ្យាប្រើប្រាស់

### Mobile App
- **Framework**: Flutter 3.16+
- **State Management**: Riverpod
- **Maps**: Google Maps / Flutter Map
- **Database**: Hive / Isar (Offline)
- **Location**: Geolocator, Location
- **Background Service**: Flutter Background Service

### Backend
- **Framework**: NestJS (Node.js + TypeScript)
- **Database**: PostgreSQL 15 + PostGIS 3.3
- **Cache**: Redis 7
- **Storage**: MinIO (S3-compatible)
- **ORM**: TypeORM
- **Validation**: Class Validator
- **Documentation**: Swagger/OpenAPI

### Admin Dashboard
- **Framework**: React 18 + TypeScript
- **Routing**: React Router v6
- **State**: Zustand
- **UI**: Tailwind CSS
- **Charts**: Recharts
- **Maps**: Leaflet / React-Leaflet

### DevOps
- **Container**: Docker + Docker Compose
- **Reverse Proxy**: Nginx
- **CI/CD**: GitHub Actions
- **SSL**: Let's Encrypt

## 📁 រចនាសម្ព័ន្ធគម្រោង

\`\`\`
smartgps/
├── mobile/                 # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── providers/     # Riverpod providers
│   │   ├── screens/       # UI screens
│   │   ├── services/      # API services
│   │   ├── models/        # Data models
│   │   └── utils/         # Utilities
│   └── pubspec.yaml
│
├── backend/               # NestJS backend
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── config/        # Configuration
│   │   ├── common/        # Guards, filters, interceptors
│   │   ├── modules/
│   │   │   ├── auth/      # Authentication
│   │   │   ├── devices/   # Device management
│   │   │   ├── parcels/   # Land parcels
│   │   │   ├── tracks/    # GPS tracks
│   │   │   ├── geofences/ # Geofences
│   │   │   ├── tools/     # GPS tools
│   │   │   └── export/    # Export service
│   │   ├── gateways/      # WebSocket gateways
│   │   └── database/      # Migrations
│   ├── package.json
│   └── Dockerfile
│
├── admin/                 # React admin dashboard
│   ├── src/
│   │   ├── main.tsx
│   │   ├── App.tsx
│   │   ├── pages/         # Dashboard pages
│   │   ├── components/    # UI components
│   │   ├── stores/        # State management
│   │   └── api/           # API client
│   ├── package.json
│   └── Dockerfile
│
├── nginx/                 # Nginx configuration
│   └── nginx.conf
│
├── docker-compose.yml     # Docker orchestration
├── .env.example          # Environment variables example
└── README.md             # Documentation
\`\`\`

## 🚀 ការតម្លើង និងដំណើរការ

### តម្រូវការប្រព័ន្ធ

- Docker & Docker Compose
- Node.js 18+ (សម្រាប់ Development)
- Flutter 3.16+ (សម្រាប់ Mobile Development)
- PostgreSQL 15 + PostGIS (ឬប្រើ Docker)

### 1. Clone Repository

\`\`\`bash
git clone https://github.com/yourusername/smartgps.git
cd smartgps
\`\`\`

### 2. Configuration

បង្កើតឯកសារ \`.env\` ពី \`.env.example\`:

\`\`\`bash
cp .env.example .env
\`\`\`

កែប្រែតម្លៃក្នុង \`.env\`:

\`\`\`env
# Database
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_USER=smartgps
DATABASE_PASSWORD=your_secure_password_here
DATABASE_NAME=smartgps_db

# JWT
JWT_SECRET=your_jwt_secret_minimum_32_characters
REFRESH_TOKEN_SECRET=your_refresh_secret_minimum_32_characters

# Redis
REDIS_PASSWORD=your_redis_password

# MinIO
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
\`\`\`

### 3. ដំណើរការជាមួយ Docker Compose

\`\`\`bash
# Build និង Start services
docker-compose up -d

# មើល logs
docker-compose logs -f

# Stop services
docker-compose down
\`\`\`

Services នឹងដំណើរការនៅ:
- **Backend API**: http://localhost:3000
- **API Docs**: http://localhost:3000/api/docs
- **Admin Dashboard**: http://localhost:5173
- **MinIO Console**: http://localhost:9001

### 4. Run Database Migrations

\`\`\`bash
# ចូលទៅក្នុង backend container
docker-compose exec backend sh

# Run migrations
npm run migration:run
\`\`\`

### 5. Development Setup (ដោយមិនប្រើ Docker)

#### Backend

\`\`\`bash
cd backend
npm install
npm run start:dev
\`\`\`

#### Admin Dashboard

\`\`\`bash
cd admin
npm install
npm run dev
\`\`\`

#### Mobile App

\`\`\`bash
cd mobile
flutter pub get
flutter run
\`\`\`

## 📚 API Documentation

នៅពេលដែល Backend ដំណើរការហើយ អ្នកអាចចូលមើល Swagger Documentation នៅ:

**http://localhost:3000/api/docs**

### ឧទាហរណ៍ API Endpoints

#### Authentication

\`\`\`bash
# Register
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "Password123!",
  "firstName": "សុខា",
  "lastName": "ចាន់"
}

# Login
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "Password123!"
}

# Send OTP
POST /api/auth/otp/send
{
  "phone": "+855123456789",
  "purpose": "phone_verification"
}
\`\`\`

#### Land Parcels

\`\`\`bash
# Create parcel
POST /api/parcels
Authorization: Bearer {token}
{
  "name": "ដីកសិកម្ម",
  "coordinates": [
    [[104.9199, 11.5564], [104.9299, 11.5564], 
     [104.9299, 11.5664], [104.9199, 11.5664], 
     [104.9199, 11.5564]]
  ]
}

# Get all parcels
GET /api/parcels
Authorization: Bearer {token}
\`\`\`

#### GPS Tools

\`\`\`bash
# Calculate area
POST /api/tools/calculate-area
{
  "coordinates": [[[...]]]
}

# Convert coordinates
POST /api/tools/convert-to-utm
{
  "latitude": 11.5564,
  "longitude": 104.9199
}
\`\`\`

## 🌐 ការ Deploy

### Production Deployment ជាមួយ Docker

1. **កំណត់ Environment Variables**

\`\`\`bash
# Production .env
NODE_ENV=production
DATABASE_PASSWORD=strong_password
JWT_SECRET=strong_secret_key
REDIS_PASSWORD=strong_redis_password
\`\`\`

2. **Build និង Deploy**

\`\`\`bash
# Build images
docker-compose -f docker-compose.yml build

# Start production services
docker-compose -f docker-compose.yml up -d
\`\`\`

3. **Setup SSL ជាមួយ Let's Encrypt**

\`\`\`bash
# Install certbot
sudo apt-get install certbot

# Generate SSL certificate
sudo certbot certonly --standalone -d yourdomain.com

# Update nginx config ជាមួយ SSL
# កែប្រែ nginx/nginx.conf
\`\`\`

### Deploy to Cloud (AWS/DigitalOcean/GCP)

1. Setup VPS/EC2 instance
2. Install Docker និង Docker Compose
3. Clone repository
4. Configure environment variables
5. Run docker-compose
6. Setup firewall (ports 80, 443)

## 🧪 ការធ្វើតេស្ត

### Backend Tests

\`\`\`bash
cd backend

# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
\`\`\`

### Frontend Tests

\`\`\`bash
cd admin

# Run tests
npm run test
\`\`\`

### Mobile Tests

\`\`\`bash
cd mobile

# Run tests
flutter test

# Integration tests
flutter test integration_test/
\`\`\`

## 📝 គណនីសាកល្បង

### Admin Dashboard

- **Email**: admin@smartgps.com
- **Password**: Admin@123456

### Mobile App

- **Phone**: +855123456789
- **Password**: User@123456

## 🔒 សុវត្ថិភាព

- ទិន្នន័យទីតាំង Encrypt (TLS + at-rest)
- JWT Authentication ជាមួយ Refresh Tokens
- Rate limiting & Request validation
- CORS protection
- Helmet security headers
- SQL injection prevention (TypeORM)
- XSS protection

## 🤝 ការរួមចំណែក

យើងសូមស្វាគមន៍ការរួមចំណែកពីអ្នកអភិវឌ្ឍន៍ទាំងអស់!

1. Fork repository
2. Create feature branch (\`git checkout -b feature/AmazingFeature\`)
3. Commit changes (\`git commit -m 'Add AmazingFeature'\`)
4. Push to branch (\`git push origin feature/AmazingFeature\`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 ក្រុមអភិវឌ្ឍ

- **Developer**: SmartGPS Team
- **Contact**: info@smartgps.com

## 🐛 រាយការណ៍បញ្ហា

សូមរាយការណ៍បញ្ហានៅ [GitHub Issues](https://github.com/yourusername/smartgps/issues)

## 📮 ទំនាក់ទំនង

- **Website**: https://smartgps.com
- **Email**: support@smartgps.com
- **Facebook**: @SmartGPSApp

---

**សូមអរគុណសម្រាប់ការប្រើប្រាស់ SmartGPS! 🙏**

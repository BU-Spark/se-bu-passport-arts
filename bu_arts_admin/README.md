# BU Art Initiative Admindashboard

## 1. Get Started

1. Go to the terminal and make sure you are in `se-bu-passport-arts/bu_arts_admin`
2. Download dependencies:
   ```bash
    $ pnpm i
   ```
3. Create `.env` file under `se-bu-passport-arts/bu_arts_admin` and add the following varaibles:
    ```text
    PUBLIC_URL="/"
    VITE_GOOGLE_MAPS_API_KEY="key"
    VITE_FIREBASE_API_KEY="key"
    VITE_FIREBASE_AUTH_DOMAIN="domain"
    VITE_FIREBASE_DATABASE_URL="url"
    VITE_FIREBASE_PROJECT_ID="id"
    VITE_FIREBASE_STORAGE_BUCKET="bucket"
    VITE_FIREBASE_MESSAGING_SENDER_ID="id"
    VITE_FIREBASE_APP_ID="id"
    VITE_CLERK_PUBLISHABLE_KEY="key"
    ```
4. Run `pnpm run dev` and you should be ready to go
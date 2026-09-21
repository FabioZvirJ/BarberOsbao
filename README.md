# barber_osbao

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Web build and deploy
--------------------

Build locally:

```bash
flutter pub get
flutter build web --release
cd build/web
python -m http.server 8000
# open http://localhost:8000
```

Serve with Docker (build produced in `build/web`):

```bash
docker build -f Dockerfile.web -t barber-osbao-web .
docker run -p 8080:80 barber-osbao-web
# open http://localhost:8080
```

Automatic deploy
----------------

Push to `main` to trigger the GitHub Actions workflow `.github/workflows/deploy_flutter_web.yml` which builds and publishes `build/web` to GitHub Pages (uses `GITHUB_TOKEN`).

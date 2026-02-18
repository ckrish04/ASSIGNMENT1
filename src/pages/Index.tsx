const Index = () => {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background">
      <div className="max-w-2xl text-center px-6">
        <h1 className="mb-4 text-4xl font-bold text-foreground">QuickCommerce Project</h1>
        <p className="text-lg text-muted-foreground mb-8">
          A complete B2C quick-commerce application (Blinkit-style) with FastAPI microservices, MongoDB, Docker, Kubernetes, and Flutter.
        </p>
        <div className="text-left bg-muted rounded-lg p-6 text-sm font-mono text-muted-foreground space-y-1">
          <p className="text-foreground font-semibold mb-2">📁 All project files are in the <code className="bg-background px-1 rounded">/project</code> folder:</p>
          <p>├── services/user-service (port 8001)</p>
          <p>├── services/product-service (port 8002)</p>
          <p>├── services/cart-order-service (port 8003)</p>
          <p>├── services/delivery-service (port 8004)</p>
          <p>├── flutter_app/ (mobile frontend)</p>
          <p>├── k8s/ (Kubernetes manifests)</p>
          <p>├── docker-compose.yml</p>
          <p>└── README.md</p>
        </div>
        <p className="mt-6 text-sm text-muted-foreground">
          Download the <code className="bg-muted px-1 rounded">project/</code> folder and run <code className="bg-muted px-1 rounded">docker-compose up --build</code> to start.
        </p>
      </div>
    </div>
  );
};

export default Index;

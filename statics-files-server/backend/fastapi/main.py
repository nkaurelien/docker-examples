from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )


@app.get("/")
def read_root():
    return {"message": "Bienvenue dans le monde sombre et mystérieux de FastAPI."}


# if __name__ == '__main__':
#     import uvicorn

#     uvicorn.run(app, host="127.0.0.1", port=8000)
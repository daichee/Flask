from app import create_app

## インスタンス生成
app = create_app()

## 実行
if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
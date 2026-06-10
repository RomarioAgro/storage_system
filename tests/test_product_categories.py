from app.models.product_category import ProductCategory


def test_product_categories_api_supports_hierarchy(client, db, sample_data):
    sample_data()

    parent_response = client.post("/api/products/categories", json={"name": "Комплектующие"})
    child_response = client.post(
        "/api/products/categories",
        json={"name": "Жесткие диски", "parent_id": parent_response.json()["id"]},
    )

    assert parent_response.status_code == 200
    assert child_response.status_code == 200
    assert child_response.json()["parent_id"] == parent_response.json()["id"]
    assert db.query(ProductCategory).filter_by(name="Жесткие диски").one().parent_id == parent_response.json()["id"]


def test_product_can_be_created_in_category(client, db, sample_data):
    sample_data()
    category_id = client.post("/api/products/categories", json={"name": "Картриджи"}).json()["id"]

    response = client.post(
        "/api/products",
        json={
            "name": "Картридж 106R",
            "sku": "CRT-106R",
            "barcode": "CRT106R",
            "unit": "pcs",
            "category_id": category_id,
        },
    )
    filtered = client.get("/api/products", params={"category_id": category_id})

    assert response.status_code == 200
    assert response.json()["category_id"] == category_id
    assert filtered.status_code == 200
    assert filtered.json()[0]["sku"] == "CRT-106R"


def test_terminal_manager_can_create_product_with_category(client, db, sample_data):
    sample_data()
    category = ProductCategory(name="Жесткие диски")
    db.add(category)
    db.commit()

    client.post("/terminal/rfid", data={"rfid_uid": "manager-card"})
    response = client.post(
        "/terminal/products",
        data={
            "name": "SSD 1TB",
            "sku": "SSD-1TB",
            "barcode": "SSD001",
            "unit": "pcs",
            "category_id": str(category.id),
        },
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert db.query(ProductCategory).filter_by(name="Жесткие диски").one().products[0].sku == "SSD-1TB"

'''
Tests for jwt flask app.
'''
import os
import json
import pytest

import main

SECRET = 'TestSecret'
TOKEN = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MDk4NDA2NTAsIm5iZiI6MTYwODYzMTA1MCwiZW1haWwiOiJya29saWpuQGdtYWlsLmNvbSJ9.LB6eOtQ4McaFIllcF5AbGRNrFhSkrkydv3NkMucLkik'
EMAIL = 'rkolijn@gmail.com'
PASSWORD = 'testron'


@pytest.fixture
def client():
    os.environ['JWT_SECRET'] = SECRET
    main.APP.config['TESTING'] = True
    client = main.APP.test_client()

    yield client


def test_health(client):
    response = client.get('/')
    assert response.status_code == 201
    assert response.json == 'Healthy'


def test_auth(client):
    body = {'email': EMAIL,
            'password': PASSWORD}
    response = client.post('/auth',
                           data=json.dumps(body),
                           content_type='application/json')

    assert response.status_code == 200
    token = response.json['token']
    assert token is not None

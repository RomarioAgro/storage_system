from types import SimpleNamespace

from app.core import client_ip


def test_loopback_client_uses_server_lan_ip(monkeypatch):
    monkeypatch.setattr(client_ip, "server_lan_ip", lambda: "192.168.0.156")
    request = SimpleNamespace(client=SimpleNamespace(host="127.0.0.1"))

    assert client_ip.client_ip_from_request(request) == "192.168.0.156"


def test_non_loopback_client_ip_is_preserved():
    request = SimpleNamespace(client=SimpleNamespace(host="192.168.0.42"))

    assert client_ip.client_ip_from_request(request) == "192.168.0.42"

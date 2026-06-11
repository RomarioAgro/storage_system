from __future__ import annotations

import ipaddress
import socket
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from fastapi import Request


def server_lan_ip() -> str | None:
    """Return the preferred local server IPv4 address.

    Returns:
        Non-loopback IPv4 address selected by the OS routing table, or a
        hostname-derived non-loopback address when routing lookup is unavailable.
    """
    routed_ip = _routed_server_ip()
    if routed_ip:
        return routed_ip
    return _hostname_server_ip()


def client_ip_from_request(request: Request) -> str | None:
    """Return the access-log client IP for an HTTP request.

    Args:
        request: FastAPI request object.

    Returns:
        Request client host. Loopback clients are replaced with the server LAN IP
        so local browser access is still traceable in the access journal.
    """
    if request.client is None:
        return None
    host = request.client.host
    if _is_loopback(host):
        return server_lan_ip() or host
    return host


def _routed_server_ip() -> str | None:
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            sock.connect(("8.8.8.8", 80))
            host = sock.getsockname()[0]
    except OSError:
        return None
    return host if _is_usable_server_ip(host) else None


def _hostname_server_ip() -> str | None:
    try:
        hostnames = socket.getaddrinfo(socket.gethostname(), None, family=socket.AF_INET)
    except OSError:
        return None
    for item in hostnames:
        host = item[4][0]
        if _is_usable_server_ip(host):
            return host
    return None


def _is_loopback(host: str) -> bool:
    if host.lower() == "localhost":
        return True
    try:
        return ipaddress.ip_address(host).is_loopback
    except ValueError:
        return False


def _is_usable_server_ip(host: str) -> bool:
    try:
        address = ipaddress.ip_address(host)
    except ValueError:
        return False
    return address.version == 4 and not address.is_loopback and not address.is_link_local

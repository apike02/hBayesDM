import pytest

from hbayesdm.models import bart_ewmv_minusrho


def test_bart_ewmv_minusrho():
    _ = bart_ewmv_minusrho(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

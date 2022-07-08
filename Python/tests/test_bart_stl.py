import pytest

from hbayesdm.models import bart_stl


def test_bart_stl():
    _ = bart_stl(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

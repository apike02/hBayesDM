import pytest

from hbayesdm.models import bart_par4_withintrial


def test_bart_par4_withintrial():
    _ = bart_par4_withintrial(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

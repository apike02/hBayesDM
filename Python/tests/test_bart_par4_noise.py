import pytest

from hbayesdm.models import bart_par4_noise


def test_bart_par4_noise():
    _ = bart_par4_noise(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

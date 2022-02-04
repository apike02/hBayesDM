import pytest

from hbayesdm.models import bart_par4_noise_riskaversion


def test_bart_par4_noise_riskaversion():
    _ = bart_par4_noise_riskaversion(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

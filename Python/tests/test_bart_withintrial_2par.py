import pytest

from hbayesdm.models import bart_withintrial_2par


def test_bart_withintrial_2par():
    _ = bart_withintrial_2par(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

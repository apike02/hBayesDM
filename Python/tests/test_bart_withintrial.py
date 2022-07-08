import pytest

from hbayesdm.models import bart_withintrial


def test_bart_withintrial():
    _ = bart_withintrial(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

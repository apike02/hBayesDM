import pytest

from hbayesdm.models import bart_withintrial_3par


def test_bart_withintrial_3par():
    _ = bart_withintrial_3par(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

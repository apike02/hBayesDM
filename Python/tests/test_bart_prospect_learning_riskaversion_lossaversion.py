import pytest

from hbayesdm.models import bart_prospect_learning_riskaversion_lossaversion


def test_bart_prospect_learning_riskaversion_lossaversion():
    _ = bart_prospect_learning_riskaversion_lossaversion(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

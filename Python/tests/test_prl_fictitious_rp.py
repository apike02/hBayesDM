import pytest

from hbayesdm.models import prl_fictitious_rp


def test_prl_fictitious_rp():
    _ = prl_fictitious_rp(example=True, niter=2, nwarmup=1, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()

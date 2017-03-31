install-inf
===========

Abstract
--------

``install-inf.pl`` is a simple **Perl script** which can be used as a lighweight replacement for `Zadig <http://zadig.akeo.ie>`_.

Motivation
----------

If you ever tried to replace a standard Windows driver for some USB device with a **libusb**-compatible one (such as the stock ``winusb.sys`` driver) then you know that it's not as simple as it sounds in the official Microsoft WinUSB guide.

Going through the Device Manager and navigating to the ``.inf``-containing folder usually ends up with messages like *"The best driver for your device is already installed"* or *"The folder you specified doesn't contain a compatible software driver for your device"*.

The trick is to *force-update* the driver. This can be achieved by calling ``UpdateDriverForPlugAndPlayDevices`` *SetupAPI* function while passing it the hardware ID of a device and the path to a particular ``.inf`` file.

Usage
-----

1. Prepare the proper ``.inf`` file as described in the official Microsoft `WinUSB guide <https://msdn.microsoft.com/en-us/library/windows/hardware/ff540283(v=vs.85).aspx>`_.

2. *[OPTIONAL]* Create a ``.cat`` file using ``inf2cat`` and sign it with ``signtool``

3. Make sure **Perl** is accessiblve via ``PATH`` environment variable. Note that you need 64-bit Perl on 64-bit Windows.

4. From an elevated command prompt run:

	.. code:: bash

		perl install-inf.pl <path-to-inf>

5. Unless you have created a properly signed ``.cat`` file, you will see a *"Windows Security"* warning stating that *"Windows can't verify the publisher of this driver software"*. When you do, fearlessly hit *"Install this driver software anyway"*.

6. Go to the Device Manager and make sure your device has moved from its original group into *"Universal Serial Bus devices"* and its name is now the same as in the ``.inf`` file.

7. Congratulations! Now you can work with your device via **libusb** API.

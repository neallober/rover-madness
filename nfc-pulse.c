#include <stdlib.h>
#include <nfc/nfc.h>

# Helper function used to dump chip ID's that are found
void print_hex(const uint8_t *pbtData, const size_t szBytes) {
  size_t szPos;

  for (szPos = 0; szPos < szBytes; szPos++) {
    printf("%02x ", pbtData[szPos]);
  }
  printf("\n");
} // End print_hex helper function


# Main program below

int main(int argc, const char *argv[]) {
  nfc_device *pnd;
  nfc_target nt;
  nfc_context *context;

  // Initialize a context for libnfc
  nfc_init(&context);
  if (context == NULL) {
    printf("Unable to init libnfc (malloc)\n");
    exit(EXIT_FAILURE);
  }

  // Display the libnfc version
  const char *acLibnfcVersion = nfc_version();
  (void)argc;

  // Open the first available NFC device
  pnd = nfc_open(context, NULL);
  if (pnd == NULL) {
    printf("ERROR: %s\n", "Unable to open NFC device.");
    exit(EXIT_FAILURE);
  }

  // Set the opened NFC device to initiator mode
  if (nfc_initiator_init(pnd) < 0) {
    nfc_perror(pnd, "nfc_initiator_init");
    exit(EXIT_FAILURE);
  }
  
  const nfc_modulation nmMifare = {
    .nmt = NMT_ISO14443A,
    .nbr = NBR_106,
  };

  // Configure various settings for the NFC reader
  const uint8_t uiPollNr = 1;
  const uint8_t uiPeriod = 1;
  const nfc_modulation nmModulations[5] = {
    { .nmt = NMT_ISO14443A, .nbr = NBR_106 },
    { .nmt = NMT_ISO14443B, .nbr = NBR_106 },
    { .nmt = NMT_FELICA, .nbr = NBR_212 },
    { .nmt = NMT_FELICA, .nbr = NBR_424 },
    { .nmt = NMT_JEWEL, .nbr = NBR_106 },
  };
  const size_t szModulations = 5;
  
  // Ask the NFC reader to poll for nearby chips
  int res = 0;
  if ((res = nfc_initiator_poll_target(pnd, nmModulations, szModulations, uiPollNr, uiPeriod, &nt))  < 0) {
    nfc_perror(pnd, "nfc_initiator_poll_target");
    nfc_close(pnd);
    nfc_exit(context);
    exit(EXIT_FAILURE);
  }

  // If an NFC chip was found, print the hex value
  if (res > 0) {
    print_hex(nt.nti.nai.abtUid, nt.nti.nai.szUidLen);
  } else {
    printf("No target found.\n");
  }

  // Close the NFC device and release the context
  nfc_close(pnd);
  nfc_exit(context);
  exit(EXIT_SUCCESS);

} /* end of main() */

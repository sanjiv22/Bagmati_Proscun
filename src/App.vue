<template>
  <div class="main-container">
    <input ref="inputField" type="text" name="membershipNo" v-model="membershipNo" placeholder="Membership No"
      class="input-field" @keydown.enter="filterByMembershipNo">
    <div class="canvas-container">
      <canvas ref="canvas" class="canvas" width="650" height="850"></canvas>
    </div>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue';
import * as XLSX from 'xlsx';

const canvas = ref(null);
const allData = ref([]);
const membershipNo = ref('');
const staticImage = ref(null)
const inputField = ref(null);
const selectedMember = ref(null)

const keepFocus = (event) => {
  // Focus the input unless it's the current active element
  if (document.activeElement !== inputField.value) {
    inputField.value.focus();
  }
};

onBeforeUnmount(() => {
  document.removeEventListener('click', keepFocus);
});


onMounted(async () => {
  document.addEventListener('click', keepFocus);

  await fetch('/AgmFormData.xlsx')
    .then((response) => response.arrayBuffer())
    .then((data) => {
      const workbook = XLSX.read(data, { type: 'array' });
      const worksheet = workbook.Sheets[workbook.SheetNames[0]];
      const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 });

      const headers = jsonData[0];

      allData.value = jsonData.slice(1).map(row => ({
        name: row[headers.indexOf('Name')] || '',
        nepali_name: row[headers.indexOf('Nepali Name')] || '',
        gender: row[headers.indexOf('Gender')] || '',
        saccos_union: row[headers.indexOf('Saccos Union')] || '',
        post: row[headers.indexOf('Post')] || '',
        email: row[headers.indexOf('Email')] || '',
        district: row[headers.indexOf('District')] || '',
        municipality: row[headers.indexOf('Municipality')] || '',
        ward_no: row[headers.indexOf('Ward No')] || '',
        mobile_no: row[headers.indexOf('Mobile No')] || '',
        membership_no: row[headers.indexOf('Membership No')] || '',
        voterNo: row[headers.indexOf('Voter ID')] || '',
        photo: row[headers.indexOf('Photo')] || '',
        mQr: row[headers.indexOf('QR')] || '',
      })).filter(row => row.name && row.nepali_name && row.gender && row.saccos_union && row.post &&
        row.email && row.district && row.municipality && row.ward_no && row.mobile_no);
    })
    .catch((error) => console.error('Error loading the Excel file:', error));

  //load background static image
  staticImage.value = await loadImage('/background-image.jpg');
  const ctx = canvas.value.getContext('2d');
  ctx.clearRect(0, 0, canvas.value.width, canvas.value.height);
  ctx.drawImage(staticImage.value, 0, 0, canvas.value.width, canvas.value.height);
});


const filterByMembershipNo = () => {
  const codeToFind = membershipNo.value.trim(); // Remove extra spaces
  selectedMember.value = allData.value.find(item => {
    return String(item.membership_no) === codeToFind;
  });

  drawDataOnCanvas(selectedMember.value);  // Draw the image only if there's a match
  membershipNo.value = ''
};

const loadImage = async (src) => {
  return await new Promise((resolve) => {
    let img = new Image();
    img.src = src;
    img.onload = () => resolve(img);
    img.onerror = (err) => resolve(null);
  });
};

const drawDataOnCanvas = async (item) => {
  const ctx = canvas.value.getContext('2d');
  ctx.clearRect(0, 0, canvas.value.width, canvas.value.height);
  ctx.drawImage(staticImage.value, 0, 0, canvas.value.width, canvas.value.height);

  try {

    if (!item) return;

    // Load and draw the signature and QR images after the background image
    const memberPhoto = await loadImage('/photo/' + item.photo);
    const memberQr = await loadImage('/qr/' + item.membership_no + '.jpg');
    //opacity = 50% (for positioning only)
    // ctx.globalAlpha = 0.7;

    // Draw the signature and QR images
    if (memberPhoto != null)
      ctx.drawImage(memberPhoto, 75, 200, 170, 200);

    if (memberQr != null)
      ctx.drawImage(memberQr, 460, 630, 145, 145);

    // Draw text details
    ctx.font = 'bold 20px Arial';
    ctx.fillStyle = 'black';
    ctx.textAlign = 'center';

    ctx.fillText(item.membership_no, 250, 685);
    ctx.fillText(item.voterNo, 285, 765);

    let address = item.district + " - " + item.ward_no + ", " + item.municipality;
    ctx.fillText(item.name, 320, 450);
    ctx.fillText(address, 320, 520);

    ctx.fillStyle = 'green';
    ctx.font = 'bold 20px Arial';
    ctx.fillText(item.saccos_union, 320, 485);

  } catch (error) {
    console.error('Error loading images:', error);
  }
};


</script>

<style scoped>
.main-container {
  display: flex;
  width: 100%;
  height: 100%;
  margin: 0 auto;
}

.canvas-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  margin: 0 auto;
  flex-grow: 2;
}

.input-field {
  width: 20%;
  height: 10%;
  border: 0px;
}
</style>

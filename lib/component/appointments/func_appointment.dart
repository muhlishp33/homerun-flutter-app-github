// Note
// if appointmentType == '', that's appointment general

dynamic _masterRollData<T>(String appointmentType) {
  return {
    'pagePath': '/masterAppointmentPage',
    'createPagePath': '/masterAppointmentCreatePage',
    'detailPagePath': appointmentType == 'resident-billing'
        ? '/iuranWargaDetailPage'
        : '/masterAppointmentDetailPage',
    'updatePagePath': '/masterAppointmentUpdatePage',
  };
}

String getAppointmentEndpointPrefix<T>(String appointmentType) {
  return appointmentType == '' || appointmentType == 'appointment' ? '' : '$appointmentType/';
}

String getAppointmentPagePath<T>(String appointmentType) {
  return _masterRollData(appointmentType)['pagePath'];
}

String getAppointmentCreatePagePath<T>(String appointmentType) {
  return _masterRollData(appointmentType)['createPagePath'];
}

String getAppointmentDetailPagePath<T>(String appointmentType) {
  return _masterRollData(appointmentType)['detailPagePath'];
}

String getAppointmentUpdatePagePath<T>(String appointmentType) {
  return _masterRollData(appointmentType)['updatePagePath'];
}

bool isAppointmentType<T>(String appointmentType) {
  switch (appointmentType) {
    case 'appointment':
    case 'ticketing':
    case 'document-request':
    case 'hand-over':
    case 'visitor':
    case 'club-house':
    case 'rt-rw':
    case 'vaccine-registration':
    case 'vaccine-registration-child':
    case 'work-out':
    case 'virtual-class':
    case 'cluster-complain':
    case 'resident-billing':
    case 'e-catalog':
    case 'survey-mitsu':
      return true;
    default:
      return false;
  }
}

String isAppointmentCreateType<T>(String appointmentType) {
  switch (appointmentType) {
    case 'create-appointment':
      return 'appointment';
    case 'create-ticketing':
      return 'ticketing';
    case 'create-document-request':
      return 'document-request';
    case 'create-hand-over':
      return 'hand-over';
    case 'create-visitor':
      return 'visitor';
    case 'create-club-house':
      return 'club-house';
    case 'create-rt-rw':
      return 'rt-rw';
    case 'create-vaccine-registration':
      return 'vaccine-registration';
    case 'create-vaccine-registration-child':
      return 'vaccine-registration-child';
    case 'create-work-out':
    case 'virtual-class':
    case 'create-virtual-class':
      return 'work-out';
    case 'create-cluster-complain':
      return 'cluster-complain';
    case 'create-resident-billing':
      return 'resident-billing';
    case 'create-e-catalog':
    case 'e-catalog':
      return 'e-catalog';
    case 'create-survey-mitsu':
      return 'survey-mitsu';
    default:
      return 'unkown';
  }
}

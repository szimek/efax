require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/efax/inbound'

module EFaxInboundTest
  class InboundPostRequestTest < Test::Unit::TestCase

    def test_receive_by_params
      EFax::InboundPostRequest.expects(:receive_by_xml).with(xml).returns(response = mock)
      assert_equal(EFax::InboundPostRequest.receive_by_params({:xml => xml}), response)
    end
    
    def test_receive_by_xml
      response = EFax::InboundPostRequest.receive_by_xml(xml)
      
      assert_equal file_contents,  response.file_contents
      assert_equal :pdf,           response.file_type
      assert_equal '098-765-4321', response.sender_fax_number
      assert_equal '098-765-4321', response.ani
      assert_equal '1234567890',   response.account_id
      assert_equal '48794686',     response.fax_name
      assert_equal '1234567890',   response.csid
      assert_equal 0,              response.status
      assert_equal 59985697,       response.mcfid
      assert_equal 1,              response.page_count
      assert_equal 'New Inbound',  response.request_type
      
      # According to docs these will always be "Pacific Time Zone" (sometimes -8, sometimes -7 -- using -8)
      assert_equal Time.utc(2009,9,29,23,56,35), response.date_received
      assert_equal Time.utc(2009,9,30, 0, 1,11), response.request_date
    end

    
    def xml
      %Q{
        <?xml version="1.0"?>
        <InboundPostRequest>
          <AccessControl>
            <UserName></UserName>
            <Password></Password>
          </AccessControl>
          <RequestControl>
            <RequestDate>09/29/2009 16:01:11</RequestDate>
            <RequestType>New Inbound</RequestType>
          </RequestControl>
          <FaxControl>
            <AccountID>1234567890</AccountID>
            <DateReceived>09/29/2009 15:56:35</DateReceived>
            <FaxName>48794686</FaxName>
            <FileType>pdf</FileType>
            <PageCount>1</PageCount>
            <CSID>1234567890</CSID>
            <ANI>098-765-4321</ANI>
            <Status>0</Status>
            <MCFID>59985697</MCFID>
            <FileContents>#{file_contents}</FileContents>
          </FaxControl>
        </InboundPostRequest>
      }
    end
    
    def file_contents
     %Q| JVBERi0xLjYKJeTjz9IKMSAwIG9iagpbL1BERi9JbWFnZUIvSW1hZ2VDL0ltYWdlSS9UZXh0XQplbmRvYmoKMyAwIG9iago8PC9TdWJ0eXBlL0ltYWdlCi9XaWR0aCAxNzI4Ci9IZWlnaHQgMjIwMAovQml0c1BlckNvbXBvbmVudCAxCi9Db2xvclNwYWNlL0RldmljZUdyYXkKL0ZpbHRlci9DQ0lUVEZheERlY29kZQovRGVjb2RlUGFybXM8PC9LIC0xL0VuZE9mQmxvY2sgZmFsc2U+PgovTGVuZ3RoIDQgMCBSCj4+CnN0cmVhbQrI4OaClTMigMHY4pFc7GxDtWKRdEDDBJSJJf///4ZvDKGHms1zvGoMEdjbTDNMMH//////w25DGaGRx5s/zwU5kciORwyOTkMedQuSA5zI5EcjMZDCunhswMuM+FygjMUuKJDCf/////////////pYRcBhieA9Aq3CL8NidxO7YlQHhFwGaAgRfh6NNsTuJ3YRcBhF+HoER7wdGhhF+GZhARdgwwgwj4oRfB//////////////////xWIbYQb0hxQQbppthBvENkiQQb8aabENoIN6TfsUKCDYRd0EG3okNBBv///////////////mmHnQT9Lj/286CcZUBjZC/8+JHpN4ShRoJ0m20nx//////////////8N4Rd/iHzV//CLvzbESXf4Rd5lFC4hVMnX7aX///////////////hBfzWH5O/9LCC/J3lGH/CC8nejUcwjk7vbSYrye////////////////8JJ0EyP/hvYYQX8MJJ0EyP2YbDCC7C/0EyPsMIJNJvTYYQTDCsMJNJsMJf////////////////+EIRmCMTuKCDCDCDCDBAwxCTTThEcicEYncUGIQYhAgbEJNNNidxQYhGgIgwmEDBAwxCDEodgxBNEMEDEL/////////////xERERERERURERERERERERERERER9B+P/////////5kFhTvo7CWD/f5pv+G/7f9yQinRqWUIgiKdfzMUoEPQQeCIvGclZHQiHB/tMJx6cWoTT+6Lxzc4Ij+jY5OxKtzc0Xj/pNpPCHp6adJ0m/9f/tf/X/2x67Gqx9v+lr8H+qX/jMwnsH+aBI/rgvsH+C/+aslnyQP9EszVfXBfg/8F/1bS/Pp/0tv9Zm/8L//mb+FurX7/7W68U2rhfbS/cK2uctMVH7H/GxX4JhMiw/YX7IsNhfEREREREREQ9fS1H///////8yWBkFjs1iUx6Px6PUEDv/+mv/9FzcER7/+kHXH/6V//+nJC2yNo1Iq0al//hE4qWaRnAiLQi+bwYIi//6QoPb9NPTT//ou/+jY0bHovGjY//6QbSv6en0m6f//V7/tbXXtf/zQIk6X9jY+3Y///+/g4PS4P///H7BsHxsH//NV6fsGwfsG7u77//Jxk4+YI//v+iz/Bwfwf/9/1fnE5xPtmtOIiI21bS38LhfzNhfYW9btb7+6vsGCTYSp2wraTaW2raRyPR+PR6hiExXxsbHsUx//DCaSsMk9hMLYTC/+IiIiIiIiIiP////////5blEdKW4kszXC4X//H//8oUIGXggefFlua/+nCDDBYYLReOv+k3v/r//t//S9f8d//hgv+ZtGg///2//mb/91sEU+wRT21x8exV99hRERH//y3KI6UtxJZmuFwv/+P//5QoQMvBA8+LLc1/9OEGGCwwWi8df9Jvf/X//b/+l6/47//DBf8zaNB///t//M3/7rYIp9gintrj49ir77CiIiP//LcojpS3Elma4XC//4///lChAy8EDz4stzX/04QYYLDBaLx1/0m9/9f/9v/6Xr/jv/8MF/zNo0H//+3/8zf/utgin2CKe2uPj2KvvsKIiI/////////mQXGZnZlHY5kzjIiO1qNx2rCk8d0M6M8FMi+VbOrOrKhkSZA465G2TBnRlVuuuVC/kMd1gyXR2LLCDBBggwgycOEGuThwg9frrhf777ChVTTTT09cJ3/mkPm2//mo/5pv1ReNF40XjReOfUu2qz1F4//+P/vwRH1w361dPT1a06qqTcER9f//+/37fhUnS0tJ9JuceF6+/+QVEmjUiMWbRTopFkGjqjUiEWQ0U6NaOqIqsoRTo6op0UiOq8i6Iou84jWjUvnH75IRTokq0WP/HH/10WP/+ceUIjEdVkhcEDJ4+z+eFIwU0EPwIHggZQKRAoIGdRARFoReN5FwGeEPQIGTimYpJwIHnxSgQERTgyIFMxPIcaR4U/Gccgg/wQMnEPQQZeLkbHuv4QM4KUCHouRsZTiBA6///0uvSb3XPimcCBggeZiHI0vt6pphOLiGmg8Jpp6eE4tNOIemE000wn/oP4+osJxxa9196YTi1CfC20qptKjFtpcLoxf3Wg4sIYT/gwX6Lxou3Nzk8cnlF40XcGCm5o2NGx6NjDBTc5PGi7aLxyedF45uaNjReNF25uftpIu/wRH/k8c3OCI/J2JVv/3DBIvHNzk7Eq3NzDBD2qmCUwVrhA0vx8IH/+i7yeObM3NtL+tJNpOk9PTaTaQb0np6fp9J6dJ0m6b0m0np0m0nSf/SDfwh1p0nhDTT7a/6TaT006T+xWE8JsUhfpehba7a6Qbp0nSf/9rXTf/9dX/tbXtf/Tdf9f7VdN//VX/gl///1/1///tRNDiaG1Lx+l8vH/11f7/19ucf7eI9dN7aT49jY9jj147dN+2PY7eI/tqk/1FVj1Vf//tj1WP4RNw4TcJsIm4dB/r6D2v+k9aWO2v/6S0l/0v9YOD4PX0kv9LWDS0l///r1/9tf9LX9fQQbp6dBBsb9fG2PbX//X/6useRgT/j/IwIwbB7B5OE/j/jMwjBx5ThP0v/mT80Cf/1/xmYT8pwnmYlPt7ZcSnfzAiXuyIP+v/80CaX37/Bf//BWDYPYPBf//BWD8F9v//8F///XwX8F/2//29/r8ML///wVv/dfMooln/mV/RLJOMnHlA9Es/zCn5qyWSccyuiWf///0Sz/7a/81ZLP6JZ/S//S+60IPx9tf/9Es//+vgv//4LBwfB+C///gsH+C/dL//4L//r6+C/4L8fffH/Uf0vr//gt0vurq22ZyX/t/pZxOcT55Ppftmc3+2lnE7bZnJf3//+l///rtpf6X///mH+Vdn3m7///0u/8VHmb//tLM22l+Fwvhf//zN2l5m/C+Zv//ptL////dfrzN///trpaTaul/ul+67aXt/9f6urStf1ur+1vv7+1+0rr+6tb7q0rX2O+1/7X/4rwvdWv9r903t91atpfa6XFd/2tqx/d21bVwv2k2rYS3CtpNpbaVgiohfbVtT1YS21cK2k2rauF/bCTYX/cL//xVgioauF/cLZHW2ErCVhJsJNpWvtpNqev2wl7auF/+xTFR/FMUxXGxsexxx+xTFcVsVGxsUxUf0xUf/H/79RsVH/HHsbFMUxsUxXsUxXvsV7HHX6phNMiw/mHTCa2RYbCYWwnZFh+0wuZ1sJkWGwmE0yLD92gyT/9kWH/9cE7CZFh/siw32EGg0wmmvaYX1teyMeyLDeIiIiIiIiIiIiIiIiIiIfERERERERxEREREREREREREREREREREREREOIiIiIiPXSVL/9LSSS1gtAsehr1URH/mSzHaeJMFzrHWJKyoZ0ZlNkIzozsEGVAyMAg7Go5EyMyG4yU41RJTIymSmv/CDCDCDOwNAgwgwgwgwgf65Jo7oisL1Ia4X/000wqaaYQaf64UKF9Qv/mMdF40XbRdvReNF20XbRP6L+Ql80hX/82v/49XT0/T09PCboN/4/j///SdJtJvS0m0m1bX////5xGpFCIos4sg0U6yhf/kuskLH/JdU9XkURrREI1LyLLJCNaIhFOiTRTo1op0SayUojFkGsnRULKEUi/OI1o6op1CB4IGfggzgp+M4EDI9ggeaoIMxAgefEPRpecv81iGqLkbGEDOC5qv86QIGa4uRsajY5GhTOCDOgpoJ5DjOBEXQGcFM4IM6CHoEDIwQ/AgZ+BAygU/HIEDCBl4uRsZoKZwIGEDOop+M4IGCIvGmDz4pECggYQPBAycUERTg/FxoPwhxfHhDCftpe3thOLXQde3txDi1p9BxphP/T0HGE4sJxDiGg+L4tU4vQf6eENNB/FpppwwUnjgiPou/y7yePgiP82ZubaVrpaXNzk7Eq2GCRd1MFpaXJ5k7Eq3wei7wRH0Xbm5/6NjBgkXeCI/Nzk8c3OTzJ5Rd+TxhgpOxKtovHJ4wwSLv4YJGx82UXjRdwYIMFJ40XjRsaLx+nhCkG/QT08g+BDpOk/sUP+k9NPpBvCY/9N00+yIYpBuEKTpP/0+kG4QpPTpPTdNpBvp+mnSbp9IN/0+k6TaQb+nSbp0m//V/v/+/9Nf//9XE0P///DB9X03//tdX///9X//1/1f+1711f/XtV+ukn9Lr60sdtQibh/49V6Twm/+m6rww9J6xH/7HSeh6x6bptJ+vqvbr0n/sdL20n+vbsdv////NV/X0EG/9f/6f///JSP/SX/g/9fX////S///g/0v/9Lg0v/////5mE0qf/NYT//b///wb/8jAn+wf+S4TynCf///8f//sH/H//Gwcf/////wVv233wX//33//3/8F/2D/wXwX///////YP///2D//////oln0u6ukSz//91df/nSIe//oln/KB/6JZ9Es////81f//KB/zK//zA3MuW//////BbpfrrBf/7+uv/t9//wX/g//BfwX///////g////g///+///S7//0v/////9f/2zOS/88n/0v0v////b//88n/b//bNSdv/tpe6/+3/02v//+2lpf9pf3V+2l//+F9tL//tK0m0v//M3+2l+F9vzNtpf+ZsL5m//fa3//a2rHdNpNpWv/e3tpNpf+2raXf2la/a39/a/a/9///df32vf2t1f/3V91sEU/2wk2FYYX/21cLthI9Wtq4U5fnKwRUMJWEj1a2thI9fnI9MGCR+gwU9ZRNhLbVwvthW0tsJbhfcLYSsJNhL+wRT/bX7I6bCTYWwinaW2rathLsEU/bVtJtcf7FRsTj//Y46Y9imKj/+NimK2KYqK//YrDFfsVsVH8bHsVx/HFRTFfx/sV8bFRxsexsUxXH7FMbFX/aDJPDX/7Ix7IsN2FtNMiw//doNbTUzr/8MLYX7W0yLD8Mk9hbWyLD9kWHM6mdNfv+wvdoMk92FsjHsJrf2EwmFEREREcRERERHEREREREREREcREREOIiIiIiIiIiIiIiIiOOIiIiIiIiIiIiIiIiIiIj0tfldKv/+klpfgwUF6+xCrH4YVfxERH/mQVf//nEa0RRGi4IGTin4zjkEGCIqYuLQfxp5PGi7/BEfRsenSDfwhp/1f+1rSf6sf//B//9g//+wf//Og//+D//80T/bS/C/77Xv+2Emwu2kcvsVHsf9oMk/YXEREREf////////mQIydk8XiXjVHaVEsjtIZPEkiHXVL87JF5JUvn1//wvhV8L+CI///82n/feOP//910v////mtZxFWjUiWrziNSzaKdHVZLrziNaNa/OL0+bgRF6CBn43AgYIGR4hxpHBTOM4IHggZoLggZQKCIvAzoKCB4IGTik4mEDwQO636cXxYQ/Qf8WnENNPQfFphP4vfpaNjk8fJ45d20kXfwwUnjReOTyi8aNjDBIu4MFJ40Xjm54YKTx/f6en6dBP6Qb/p0m6bSbp9IN9Ok2k/0/q/2v/36q//r+va6v+v/+69djX1pbapP/Xt03t2Ok/Xtj/Xv14P/////S/S4P/9LX/9P7B//+l//x/Gwf/8Z8J/9b9g//9v///9g//8F/7/WUD/////5ifmBv/+aoln/364P//ul///4P//wX/+n88n/++///b9s1J//20v/xx4X/916bS//M3aWZsL7aX+Zv/+9d//3sd9r/da3V/f/dWv/320v/YYXbCTYWwRT9tbSbVtKyOmwl+2rhewRT89a9j/9icfTFRx+xUUxTHGxX7FR8f/rYX/hrdoMk9/YUw6YTCdr9hMiw9/4iIiIiI+IiIiIiIiIiIiIiIh+kstxl/0kksGCgtWIVDDCqI////////zIliRHWJEdggIQWIcQbJAEGI1RAgIMW/4P//6/3//+CI9/Md/kReRa6/++P4///ff/7f5IRrRrRTo1ryGjWsgSrziINecRrRTo1Kl/mYpOKCBkePimcEH5oKTi55mI5Agf4IGfgRFCcEDJxD0CBggZHu3+g0whpx+g09Li/i9PiwnFhD/+i7ovHLui8cER/VF3RdvS5PGPJ49Gx8njm5yeOXelfGkG0m0E6TcIcJJBtJ9Lp+n6fp0np0E/f6uveviqum9L//2v//el+k+2l7dUk+Ol19fY9Y9aX75iPpfpfBelFf/8H+v/j/+P4+bw/7//2D/NAn/T///9v+//9g/wX///zVeavv/Lf//k4/0Sz/0Wf///9/03//g/8F/+r/9u9v2/bM7v//OJ/0v7+/7aWZt1zN+7aX7//4X//3Wt/33V91932lt//9/9r9+n/bCTasMK2uaW22Em17//20v3C+wwv/2KYpicexX+xTFb//7H/H7E4+lf7TCDWwv22mu//9hfsiw/DXEREREcRDiIiIiIiIiIiIiIj9eW4y8t1F9JLSwYLUGC2IQsQoYQYUR/5kFhSeO6GdGeCkQBGQx3WD999+aj/mmyEu/BEfXDf3+/b/ecRrRqXzj981op1/BAycQ9BBl4uRse6/5DFKBD0XI2P1FhOOLXuvvTCcWv5PHNzgiPydiVb/99F45ucnYlW+tOk8IaafbX/SbSemn4Jf//9f9f/4qseqr//9seq9ev/tr/pa/5k/NAn/9f8ZmE//gv//6+C//0Sz/7a/81ZLP/+C//6+vgv/+l///rtpf////dfrzN///tf/ivC91a//3C//8Vtq4X//H/79bFR//2RYf/1wWwmRYf8RERERERERERER//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////gAgAgplbmRzdHJlYW0KZW5kb2JqCjQgMCBvYmoKNTIyNQplbmRvYmoKNiAwIG9iago8PC9MZW5ndGggNyAwIFIKL0ZpbHRlci9GbGF0ZURlY29kZQo+PgpzdHJlYW0KeJwr5DIzsNSzsDAyUTAAQgsDCz1DM2NjMCc5l0vf00DBJZ8rkAsAoiwH9AplbmRzdHJlYW0KZW5kb2JqCjcgMCBvYmoKNDMKZW5kb2JqCjggMCBvYmoKPDwvUHJvY1NldCAxIDAgUgovWE9iamVjdDw8L0kwIDMgMCBSCj4+Cj4+CmVuZG9iago5IDAgb2JqCjw8L0NyZWF0aW9uRGF0ZSAoRDoyMDA5MDkyOTE2MDEwNC0wNycwMCcpCi9Qcm9kdWNlciAoUERGbGliIDcuMC4zIFwoSkRLIDEuNi9XaW4zMlwpKQo+PgplbmRvYmoKNSAwIG9iago8PC9UeXBlL1BhZ2UKL1BhcmVudCAyIDAgUgovQ29udGVudHMgNiAwIFIKL1Jlc291cmNlcyA4IDAgUgovTWVkaWFCb3hbMCAwIDYwOS44ODI0IDgwOC4xNjMzXQo+PgplbmRvYmoKMiAwIG9iago8PC9UeXBlL1BhZ2VzCi9Db3VudCAxCi9LaWRzWyA1IDAgUl0+PgplbmRvYmoKMTAgMCBvYmoKPDwvVHlwZS9DYXRhbG9nCi9QYWdlcyAyIDAgUgo+PgplbmRvYmoKeHJlZgowIDExCjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAxNSAwMDAwMCBuIAowMDAwMDA1OTEwIDAwMDAwIG4gCjAwMDAwMDAwNjMgMDAwMDAgbiAKMDAwMDAwNTQ4NSAwMDAwMCBuIAowMDAwMDA1Nzk5IDAwMDAwIG4gCjAwMDAwMDU1MDUgMDAwMDAgbiAKMDAwMDAwNTYyMCAwMDAwMCBuIAowMDAwMDA1NjM4IDAwMDAwIG4gCjAwMDAwMDU2OTYgMDAwMDAgbiAKMDAwMDAwNTk2NCAwMDAwMCBuIAp0cmFpbGVyCjw8L1NpemUgMTEKL1Jvb3QgMTAgMCBSCi9JbmZvIDkgMCBSCi9JRFs8MEQwRUE4MjY5NkUzRkJBRDlCNjJGQjY5RkQzQjNFMkU+PDBEMEVBODI2OTZFM0ZCQUQ5QjYyRkI2OUZEM0IzRTJFPl0KPj4Kc3RhcnR4cmVmCjYwMTIKJSVFT0YK|
    end
  end
end

